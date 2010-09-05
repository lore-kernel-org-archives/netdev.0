From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: net: af_packet: skb_orphan should be avoided in TX path.
Date: Mon, 6 Sep 2010 01:51:08 +0800
Message-ID: <AANLkTineDkP1EGsTn3GU+9cPO+JnaNc3ekoHyKQa=img@mail.gmail.com>
References: <AANLkTi=oXDgEhEjt7V+Z4Pk8kv9X4Z8aCg2yAJDzuJ1J@mail.gmail.com> <1283708635.3402.100.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33556 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091Ab0IERv3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Sep 2010 13:51:29 -0400
Received: by wwj40 with SMTP id 40so5432250wwj.1
        for <netdev@vger.kernel.org>; Sun, 05 Sep 2010 10:51:28 -0700 (PDT)
In-Reply-To: <1283708635.3402.100.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 6, 2010 at 1:43 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le lundi 06 septembre 2010 =E0 01:18 +0800, Changli Gao a =E9crit :
>> af_packet uses tpacket_destruct_skb() to notify its user a frame is
>> sent out through NIC, and the memory for that frame is available for
>> the others. If the driver calls skb_orphan() before the frame is sen=
t
>> out successfully, and the user may fill other data into the space fo=
r
>> this frame, this frame will be corrupted. It became more likely afte=
r
>> skb_try_orphan() was added into dev_hard_start_xmit().
>>
>> Am I correct?
>>
>
> Yes good catch. We might add a :
>
> SKBTX_NO_EARLY_ORPHAN =3D 1 << 4,
>
> so that skb_orphan_try() do not early orphan this kind of skb
>

It may solve the issue of skb_orphan_try(), but some NICs still call
skb_orphan(). Maybe replacing skb_orphan() with skb_orphan_try() can
work around this issue.

localhost linux # grep skb_orphan drivers/net/ -r
drivers/net/can/dev.c:                  skb_orphan(skb);
drivers/net/mlx4/en_tx.c:               skb_orphan(skb);
drivers/net/cxgb3/sge.c:                skb_orphan(skb);
drivers/net/cxgb4/sge.c:                skb_orphan(skb);
drivers/net/niu.c:              skb_orphan(skb);
drivers/net/cxgb4vf/sge.c:              skb_orphan(skb);
drivers/net/tun.c:      skb_orphan(skb);
drivers/net/virtio_net.c:       skb_orphan(skb);
drivers/net/loopback.c: skb_orphan(skb);
drivers/net/wireless/mac80211_hwsim.c:  skb_orphan(skb);
drivers/net/wireless/libertas/tx.c:             skb_orphan(skb);

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
