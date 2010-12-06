From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: kernel panic with time-stamping in phy devices (monitor mode)
Date: Mon, 6 Dec 2010 08:01:23 +0800
Message-ID: <AANLkTinFEUd5vuBu98COXMRGMFcpwtu_dsw=_=cN6oZJ@mail.gmail.com>
References: <906429.41845.qm@web111015.mail.gq1.yahoo.com> <1291551879.2806.253.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Watts <akwatts@ymail.com>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	stable@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54216 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621Ab0LFABp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 19:01:45 -0500
Received: by fxm20 with SMTP id 20so3745451fxm.19
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 16:01:44 -0800 (PST)
In-Reply-To: <1291551879.2806.253.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 5, 2010 at 8:24 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le samedi 04 d=E9cembre 2010 =E0 12:46 -0800, Andrew Watts a =E9crit =
:
>
>> Eric, I echo the thanks on the lightning patch.
>> Impressive turnaround!
>>
>> There's an open bug report on the kernel's bugzilla
>> for 2.6.36 (#24102). What is the best way to tie these
>> together?
>
> Thanks Andy, here is the official patch submission I am going to make=
=2E
>
> [PATCH net-2.6] net: fix skb_defer_rx_timestamp()
>
> After commit c1f19b51d1d8 (net: support time stamping in phy devices.=
),
> kernel might crash if CONFIG_NETWORK_PHY_TIMESTAMPING=3Dy and
> skb_defer_rx_timestamp() handles a packet without an ethernet header.
>
> Fixes kernel bugzilla #24102
>
> Reference: https://bugzilla.kernel.org/show_bug.cgi?id=3D24102
> Reported-and-tested-by: Andrew Watts <akwatts@ymail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Richard Cochran <richardcochran@gmail.com>
> Cc: stable@kernel.org
> ---
> =A0net/core/timestamping.c | =A0 =A06 ++++--
> =A01 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/core/timestamping.c b/net/core/timestamping.c
> index 0ae6c22..c4fbf85 100644
> --- a/net/core/timestamping.c
> +++ b/net/core/timestamping.c
> @@ -96,11 +96,13 @@ bool skb_defer_rx_timestamp(struct sk_buff *skb)
> =A0 =A0 =A0 =A0struct phy_device *phydev;
> =A0 =A0 =A0 =A0unsigned int type;
>
> - =A0 =A0 =A0 skb_push(skb, ETH_HLEN);
> + =A0 =A0 =A0 if (skb->data - ETH_HLEN < skb->head)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;

How about using skb_headroom(skb) < ETH_HLEN ?

And I checked the code of skb_push(). If the headroom of a skb is less
than the requested, Linux will panic with a message titled
"skb_under_panic()". But I can't find this info in the Oops. Maybe the
Oops isn't complete.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
