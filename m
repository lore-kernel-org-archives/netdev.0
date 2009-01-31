From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Fri, 30 Jan 2009 16:36:00 -0800
Message-ID: <20090130163600.0be8c137@extreme>
References: <20090130112125.GA9908@ioremap.net>
	<20090130125337.GA7155@gondor.apana.org.au>
	<20090130095737.103edbff@extreme> <498349F7.4050300@cosmosbay.com>
	<20090130215008.GB12210@ioremap.net> <49837F7E.90306@cosmosbay.com>
	<20090130225113.GA13977@ioremap.net>
Reply-To: Fedora/Linux Management Tools <et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Return-path: <et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <20090130225113.GA13977-i6C2adt8DTjR7s880joybQ@public.gmane.org>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/et-mgmt-tools>,
	<mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/et-mgmt-tools>
List-Post: <mailto:et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Help: <mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/et-mgmt-tools>,
	<mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=subscribe>
Sender: et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Errors-To: et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 31 Jan 2009 01:51:14 +0300
Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org> wrote:

> On Fri, Jan 30, 2009 at 11:30:22PM +0100, Eric Dumazet (dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org) wrote:
> > > It should contain rough number of sockets, there is no need to be very
> > > precise because of this hueristic.
> > 
> > Denying there is a bug is... well... I dont know what to say.
> > 
> > I wonder why we still use atomic_t all over the kernel.
> 
> It is not a bug. It is not supposed to be precise. At all.
> I implemented a simple heuristic on when diferent bind port selection
> algorithm should start: roughly when number of opened sockets equals to
> some predefined value (sysctl at the moment, but it could be 64k or
> anything else), so if that number is loosely maintained and does not
> precisely corresponds to the number of sockets, it is not a problem.
> 
> You also saw 'again' lavel which has magic 5 number - it is another
> heuristic - since lock is dropped atfer the bind bucket check, and we
> selected it, it is possible that non-reuse socket will be added into the
> bucket, so we will have to rerun the process again. I limited this to
> the 5 attempts only, since it is better than what we have right now (I
> never saw more than 2 attempts needed in the tests), when number of
> bound sockets does not exceed 64k.
> 
>

How is any of this supposed to fix the bug?
