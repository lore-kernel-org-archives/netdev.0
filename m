From: =?UTF-8?B?TmljY29sw7IgQmVsbGk=?= <darkbasic@linuxsystems.it>
Subject: Re: [Bug 42809] New: kernel panic when receiving an ipsec packet
Date: Thu, 23 Feb 2012 14:45:49 +0100
Message-ID: <4F46430D.3060802@linuxsystems.it>
References: <bug-42809-100@https.bugzilla.kernel.org/>   <20120222092056.5fca788b@nehalam.linuxnetplumber.net>   <4F4528CE.7080702@linuxsystems.it> <4F458F82.3060808@linuxsystems.it>  <1329961083.15610.2.camel@edumazet-laptop>  <4F459E37.9010507@linuxsystems.it> <1329962785.15610.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>,
	openadsl-users@lists.sourceforge.net,
	openadsl-devel@lists.sourceforge.net, 660804@bugs.debian.org,
	support@traverse.com.au, support@rocksolidelectronics.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxsystems.it ([2.119.245.41]:43265 "EHLO
	mail.linuxsystems.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281Ab2BWNpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 08:45:42 -0500
In-Reply-To: <1329962785.15610.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 23/02/2012 03:06, Eric Dumazet ha scritto:
> Thanks !
>
> Please try following patch.
>
> diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunne=
l.c
> index 534972e..f170933 100644
> --- a/net/ipv4/xfrm4_mode_tunnel.c
> +++ b/net/ipv4/xfrm4_mode_tunnel.c
> @@ -84,9 +84,11 @@ static int xfrm4_mode_tunnel_input(struct xfrm_sta=
te *x, struct sk_buff *skb)
>   	if (!(x->props.flags&  XFRM_STATE_NOECN))
>   		ipip_ecn_decapsulate(skb);
>
> -	old_mac =3D skb_mac_header(skb);
> -	skb_set_mac_header(skb, -skb->mac_len);
> -	memmove(skb_mac_header(skb), old_mac, skb->mac_len);
> +	if (skb_mac_header_was_set(skb)) {
> +		old_mac =3D skb_mac_header(skb);
> +		skb_set_mac_header(skb, -skb->mac_len);
> +		memmove(skb_mac_header(skb), old_mac, skb->mac_len);
> +	}
>   	skb_reset_network_header(skb);
>   	err =3D 0;
>

Your patch does solve the problem, thanks!

Niccol=C3=B2
