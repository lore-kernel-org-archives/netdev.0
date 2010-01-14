From: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Subject: Re: [PATCH] tcp: Generalized TTL Security Mechanism
Date: Thu, 14 Jan 2010 12:22:16 +0100
Message-ID: <20100114112216.GK12241@basil.fritz.box>
References: <20100110220034.4d46ba8a@nehalam> <873a29eywq.fsf@basil.nowhere.org> <20100114.030454.16178889.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org, shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100114.030454.16178889.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 14, 2010 at 03:04:54AM -0800, David Miller wrote:
> From: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
> Date: Thu, 14 Jan 2010 11:58:13 +0100
> 
> > Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org> writes:
> >>
> >> Only TCP is supported, but could also be added to UDP, DCCP, SCTP
> >> if desired.
> > 
> > Perhaps I'm blind, but where is the default set if the socket
> > option is not used? 
> 
> Socket allocation memset()'s it to zero.

Yes, but there's no special case for zero in the check path?

It's just

+       if (iph->ttl < inet_sk(sk)->min_ttl)
+               goto discard_and_relse;

I'm probably missing something, but naively I would expect all 
packets with ttl > 0 to be discarded then when min_ttl is zero.

-Andi
-- 
ak-VuQAYsv1563Yd54FQh9/CA@public.gmane.org -- Speaking for myself only.
