From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next 7/8] net: ip_tunnel: remove 'csum_help' argument
 to iptunnel_handle_offloads
Date: Mon, 11 Jan 2016 17:31:36 +0000
Message-ID: <5693E6F8.7040806@solarflare.com>
References: <56901197.8040808@solarflare.com>
 <56901244.8060809@solarflare.com>
 <CAKgT0UdQzW2+n7S3YOhAJVZY-q5bjYaQB0jDn7AD3zp2ZrkGZg@mail.gmail.com>
 <CALx6S34MRoLw_JiHuyDANwoF9+u7k9R-UDb_RGP+L-d9D=f3WQ@mail.gmail.com>
 <CAKgT0UeZwSm4oKoydXWU3iWmjL5m6H=K=hJ2wAkp_GugbZJwjA@mail.gmail.com>
 <5693AD25.4020904@solarflare.com>
 <CAKgT0Ufw9djq-V8YAXjq21gg7rE5=-Dp4o4GmdGk+6Diu4mDNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:4785 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933885AbcAKRby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 12:31:54 -0500
In-Reply-To: <CAKgT0Ufw9djq-V8YAXjq21gg7rE5=-Dp4o4GmdGk+6Diu4mDNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/16 16:39, Alexander Duyck wrote:
> Your first patch is probably the best place for it.  Then when you
> start setting false it doesn't introduce any errors.
Will do.
> Also I was doing a bit more work on the lco_csum function and think I
> have come up with something a bit more elegant[...]  What I will do is
> email you the full patch and the GSO patch I have as RFCs to look over
> and possibly incorporate into your own.
<snip>
> +static inline __wsum lco_csum(struct sk_buff *skb)
> +{
> +       unsigned char *csum_start = skb_checksum_start(skb);
> +       unsigned char *l4_hdr = skb_transport_header(skb);
> +       __wsum partial;
> +
> +       partial = ~csum_unfold(*(__force __sum16 *)(csum_start +
> +                                                   skb->csum_offset));
> +       return csum_partial(l4_hdr, csum_start - l4_hdr, partial);
> +}
> +
Looks OK to me.  I'd rather tack both of your patches onto the endof the
 series, rather than incorporating your patch [1/2] directly into my patch
 [1/8]; that way (a) the history allows to understand regular LCO before
 adding in the GSO flavour, (b) you're credited for your improved lco_csum.
As for your patch [2/2], I don't pretend to understand GSO right now but it
 looks plausible enough.  Perhaps you could add a document about GSO to go
 alongside the checksum-offloads.txt one?
What testing haveyou done on your series?  When rebasing it I'll focus on
 the tunnel types you haven't already tested.

-ed
