From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: wireless vs. alignment requirements
Date: Sun, 25 Nov 2007 09:44:46 +0800
Message-ID: <20071125014446.GA32104@gondor.apana.org.au>
References: <E1IvoID-0006aR-00@gondolin.me.apana.org.au> <1195893216.4149.186.camel@johannes.berg> <20071124133200.GA27531@gondor.apana.org.au> <1195912176.4149.194.camel@johannes.berg> <20071124141319.GA27819@gondor.apana.org.au> <1195938799.4149.197.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1195938799.4149.197.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 24, 2007 at 10:13:19PM +0100, Johannes Berg wrote:
>
> Eight bytes really sucks for wireless, many things are multiples of four
> and QoS vs. non-QoS frames have a multiple of four and common hardware
> only adds two padding bytes to get it aligned on four bytes so there's
> no easy way to get hardware to align it properly. Hmm.

Sorry I was wrong about the 8 bytes requirement.  Although the
IPv6 protocol does try to maintain an 8-byte alignment the Linux
stack never does anything that requires that.

So 4 bytes is enough.

However, the wireless core is definitely not out of the woods.
It needs to support variable hardware header lengths that are
not always a multiple of 4.

So here's my suggestion.  Modify the wireless core to fix up any
packets which aren't aligned correctly.  That should make it
work albeit in a way that's less than optimal.

Then for each driver where you care about this performance
(seriously I wouldn't for the speeds these things run at :),
pick the most common wireless hardware header length and have
the IP (or any other upper-level protocol) header aligned to
at least 4 bytes.  Or better if you know what hardware header
length that you're going to get (e.g., based on what mode you're
in) then do the skb_reserve accordingly.

It's a good thing these things aren't running at 10Gb :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
