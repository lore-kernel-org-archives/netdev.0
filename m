From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [1/2] tun: Only free a netdev when all tun descriptors
	are	closed
Date: Fri, 24 Apr 2009 20:11:56 +0800
Message-ID: <20090424121156.GA28039@gondor.apana.org.au>
References: <20090415083610.GA8579@gondor.apana.org.au>
	<20090415143834.GA12384@gondor.apana.org.au>
	<20090416110818.GA20950@gondor.apana.org.au>
	<200904241055.49794.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, lguest-mnsaURCQ41sdnm+yROfE0A@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, virtualization-qjLDD68F18O7TbgM5vRIOg@public.gmane.org,
	Matias Zabaljauregui <zabaljauregui-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200904241055.49794.borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
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

On Fri, Apr 24, 2009 at 10:55:49AM +0200, Christian Borntraeger wrote:
> Am Thursday 16 April 2009 13:08:18 schrieb Herbert Xu:
>
> > Here's the patch.  I'd appreciate if everyone can review it
> > and see if they can recreate the original race by
> > 
> > 1) Starting a process using tun and polls on it;
> > 2) Doing ip tun del tunXXX while the process is polling.
> > 
> > tun: Only free a netdev when all tun descriptors are closed
> > 
> > The commit c70f182940f988448f3c12a209d18b1edc276e33 ("tun: Fix
> > races between tun_net_close and free_netdev") fixed a race where
> > an asynchronous deletion of a tun device can hose a poll(2) on
> > a tun fd attached to that device.
> 
> Sorry for the late reply, but this patch creates another regression:
> Now TUNSETIFF returns EBUSY on a persistent tap device:
> 
> open("/dev/net/tun", O_RDWR) = 11
> ioctl(11, 0x400454ca, 0x3ffff8e2270) = -1 EBUSY (Device or resource busy)

The patch you qouted has been superceded by many versions :)

Can you please test the latest that's in davem's tree?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
