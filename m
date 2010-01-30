From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] skbuff: align sk_buff::cb to 64 bit
Date: Sat, 30 Jan 2010 08:07:00 +0100
Message-ID: <1264835220.2919.10.camel@edumazet-laptop>
References: <4B637F85.8080809@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Lennert Buytenhek <buytenh@wantstofly.org>,
	David Daney <ddaney@caviumnetworks.com>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:60594 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245Ab0A3HHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 02:07:04 -0500
Received: by bwz27 with SMTP id 27so1969386bwz.21
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 23:07:02 -0800 (PST)
In-Reply-To: <4B637F85.8080809@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 30 janvier 2010 =C3=A0 01:38 +0100, Felix Fietkau a =C3=A9cri=
t :
> The alignment requirement for 64-bit load/store instructions on ARM i=
s
> implementation defined. Some CPUs (such as Marvell Feroceon) do not
> generate an exception, if such an instruction is executed with an
> address that is not 64 bit aligned. In such a case, the Feroceon
> corrupts adjacent memory, which showed up
> in my tests as a crash in the rx path of ath9k that only occured with
> CONFIG_XFRM set. This crash happened, because the first field of the
> mac80211 rx status info in the cb is an u64, and changing it corrupte=
d
> the skb->sp field.
>=20
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> Cc: stable@kernel.org
> ---
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -329,7 +329,7 @@ struct sk_buff {
>  	 * want to keep them across layers you have to do a skb_clone()
>  	 * first. This is owned by whoever has the skb queued ATM.
>  	 */
> -	char			cb[48];
> +	char			cb[48] __aligned(8);
>   	unsigned int		len,
>  				data_len;
>=20
> --

Without a detailed analysis of holes added on x86_32 and/or x86_64, I
guess this patch is not acceptable as is.

You certainly can find a better way to do this, without adding holes in
sk_buff structure. Size matters a lot :)

Thanks


