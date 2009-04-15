From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH 4/5] lguest: use KVM hypercalls
Date: Wed, 15 Apr 2009 21:46:10 +0800
Message-ID: <20090415134610.GA11683@gondor.apana.org.au>
References: <1239224319.17844.16.camel@zetabook> <49DDE91A.8060603@trash.net>
	<49DDF614.1060909@trash.net> <m1bpr6hqrm.fsf@fess.ebiederm.org>
	<49E47976.8020005@trash.net>
	<20090415083610.GA8579@gondor.apana.org.au>
	<20090415084717.GA8829@gondor.apana.org.au>
	<m18wm2rqy6.fsf@fess.ebiederm.org>
	<20090415132802.GA11408@gondor.apana.org.au>
	<m1skkaox8h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, virtualization-qjLDD68F18O7TbgM5vRIOg@public.gmane.org,
	Matias Zabaljauregui <zabaljauregui-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1skkaox8h.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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

On Wed, Apr 15, 2009 at 06:35:58AM -0700, Eric W. Biederman wrote:
> 
> Because as far as I can tell we would just leak that refcount.
> 
> The poll code does not appear to call back into any of the file
> methods when it frees itself from the wait queue.

OK my suggestion was stupid.

But I still don't see how this race is possible at all.

So process A has a tun fd open and is spinning in poll(2).  Now
process B comes along and deletes that tun device.  Process A's
fd should have a netdev reference that keeps the device and
associated structures alive.

Oh I see what's going on.  We're automatically detaching the
device in uninit.  This is just wrong.  Just because process B
deleted the netdev, process A should not be involutarily detached.

Does anything actually rely on this behaviour?

If not we should just change it to not do that.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
