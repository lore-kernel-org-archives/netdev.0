From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8169: Support for byte queue limits
Date: Mon, 19 Dec 2011 10:46:04 +0100
Message-ID: <1324287964.3323.107.camel@edumazet-laptop>
References: <igorm@etf.rs> <1324286878-3950-1-git-send-email-igorm@etf.rs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, nic_swsd@realtek.com,
	romieu@fr.zoreil.com, therbert@google.com
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:65061 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752Ab1LSJqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 04:46:08 -0500
Received: by wibhm6 with SMTP id hm6so859988wib.19
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 01:46:07 -0800 (PST)
In-Reply-To: <1324286878-3950-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 d=C3=A9cembre 2011 =C3=A0 10:27 +0100, igorm@etf.rs a =C3=A9=
crit :
> From: Igor Maravic <igorm@etf.rs>
>=20
> Changes to r8169 to use byte queue limits.
>=20
> Signed-off-by: Igor Maravic <igorm@etf.rs>
> ---
>  drivers/net/ethernet/realtek/r8169.c |   13 +++++++++++--
>  1 files changed, 11 insertions(+), 2 deletions(-)
>=20

What are the changes in this version, versus prior submissions ?

> =20
>  static void rtl8169_schedule_work(struct net_device *dev, work_func_=
t task)
> @@ -5460,6 +5461,8 @@ static int rtl8169_xmit_frags(struct rtl8169_pr=
ivate *tp, struct sk_buff *skb,
>  		txd->opts1 |=3D cpu_to_le32(LastFrag);
>  	}
> =20
> +	netdev_sent_queue(tp->dev, skb->len);
> +
>  	return cur_frag;
> =20

Ignoring a review/comment/suggestion is not very wise, since I wont Ack
this patch as is, and I'll remember for your next patches that you dont
care of me taking the time to review your work.

Your choice.

Please call this from rtl8169_start_xmit() instead.
=20
	netdev_sent_queue(dev, skb->len);
