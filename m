From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH][v3] dev : fix mtu check when TSO is enabled
Date: Tue, 22 Mar 2011 01:05:46 +0100
Message-ID: <AANLkTikhqMdLV4jObYNuFcxmwFMkuLKJ+d1xtjw83Jou@mail.gmail.com>
References: <1300135190-14093-1-git-send-email-daniel.lezcano@free.fr> <20110314.165929.232913682.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: daniel.lezcano@free.fr, eric.dumazet@gmail.com, kaber@trash.net,
	nightnord@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:43681 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500Ab1CVAGI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 20:06:08 -0400
Received: by qyg14 with SMTP id 14so5534540qyg.19
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2011 17:06:07 -0700 (PDT)
In-Reply-To: <20110314.165929.232913682.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/3/15 David Miller <davem@davemloft.net>:
> From: Daniel Lezcano <daniel.lezcano@free.fr>
> Date: Mon, 14 Mar 2011 21:39:50 +0100
>> +
>> + =C2=A0 =C2=A0 /* if TSO is enabled, we don't care about the length=
 as the packet
>> + =C2=A0 =C2=A0 =C2=A0* could be forwarded without being segmented b=
efore
>> + =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 if (skb->dev && skb->dev->features & NETIF_F_TSO)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return true;
> I am trying to understand why you aren't simply checking also if this
> is a segmented frame? =C2=A0Perhaps skb_is_gso() && device has NETIF_=
=46_TSO
> set?

Is the check of netdev features even necessary? Devices without TSO
enabled the skbs are segmented before ndo_start_xmit() anyway.

With TSO there's a question if the receiving end of macvlan can handle
GRO/LRO packets?

BTW, checking only NETIF_F_TSO will break at least for IPv6 TSO
(NETIF_F_TSO6) or whatever else can be segmented in hardware.

Best Regards,
Micha=C5=82 Miros=C5=82aw
