From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 4/5] lguest: use KVM hypercalls
Date: Wed, 15 Apr 2009 07:18:44 -0700
Message-ID: <m1iql6m24b.fsf@fess.ebiederm.org>
References: <49DDF614.1060909@trash.net> <m1bpr6hqrm.fsf@fess.ebiederm.org>
	<49E47976.8020005@trash.net>
	<20090415083610.GA8579@gondor.apana.org.au>
	<20090415084717.GA8829@gondor.apana.org.au>
	<m18wm2rqy6.fsf@fess.ebiederm.org>
	<20090415132802.GA11408@gondor.apana.org.au>
	<m1skkaox8h.fsf@fess.ebiederm.org>
	<20090415134610.GA11683@gondor.apana.org.au>
	<m11vruovu5.fsf@fess.ebiederm.org>
	<20090415140819.GA11991@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, virtualization-qjLDD68F18O7TbgM5vRIOg@public.gmane.org,
	Matias Zabaljauregui <zabaljauregui-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
In-Reply-To: <20090415140819.GA11991-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org> (Herbert Xu's
	message of "Wed\, 15 Apr 2009 22\:08\:19 +0800")
List-Unsubscribe: <https://ozlabs.org/mailman/options/lguest>,
	<mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
List-Help: <mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/lguest>,
	<mailto:lguest-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=subscribe>
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org> writes:

> On Wed, Apr 15, 2009 at 07:06:10AM -0700, Eric W. Biederman wrote:
>>
>> There is the boring rmmod case that has always existed.
>> 
>> There is more interesting case of moving your tap device
>> into another network namespace.
>> 
>> In which case there is the possibility of the network namespace
>> exiting and destroying all of the virtual network devices before
>> we close the file handle.
>
> In that case what's the problem with holding a refcount to the
> unregistered device until the process owning the fd closes it?

Network devices do not hold a network namespace alive.  Only sockets
and processes do.

So holding the reference only blocks us indefinitely in
netdev_wait_allrefs, blocking the network namespace exit, and holding
net_mutex indefinitely.

My gut feel is that the socket needs to live in tun_file.  Instead
of in tun_struct.  Making that change looked just tricky enough
I couldn't sort through it when I glanced at the tun code, after I noticed
you had added a socket.

Eric
