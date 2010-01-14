From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] tcp: Generalized TTL Security Mechanism
Date: Thu, 14 Jan 2010 03:27:39 -0800 (PST)
Message-ID: <20100114.032739.217960336.davem@davemloft.net>
References: <873a29eywq.fsf@basil.nowhere.org>
	<20100114.030454.16178889.davem@davemloft.net>
	<20100114112216.GK12241@basil.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100114112216.GK12241-u0/ZJuX+froe6aEkudXLsA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Date: Thu, 14 Jan 2010 12:22:16 +0100

> It's just
> 
> +       if (iph->ttl < inet_sk(sk)->min_ttl)
> +               goto discard_and_relse;
> 
> I'm probably missing something, but naively I would expect all 
> packets with ttl > 0 to be discarded then when min_ttl is zero.

Andi, the feature works from top to bottom.

The idea is that the min_ttl is set very high, so that
you'll only accept packets from hosts that started with
a ttl of 255 and are within a hop or two from you.  (therefore
you'd set min_ttl to 254 or 253, something like that)

Since the ttl can never be less than zero, the test
will never hit when min_ttl is zero, and thus this is
that state where the socket option is not enabled.
