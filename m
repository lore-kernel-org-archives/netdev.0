From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH 2/2] ipv4: Change rt->rt_iif encoding.
Date: Wed, 25 Jul 2012 00:25:26 +0200
Message-ID: <500F20D6.806@gmail.com>
References: <20120723.160541.184307938805782289.davem@davemloft.net> <20120723.161446.36265037346365173.davem@davemloft.net> <500F1E23.7090803@gmail.com> <20120724.151801.1576915988616906722.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33107 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754402Ab2GXWYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 18:24:18 -0400
Received: by wibhr14 with SMTP id hr14so67582wib.1
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 15:24:17 -0700 (PDT)
In-Reply-To: <20120724.151801.1576915988616906722.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/07/2012 00:18, David Miller a =E9crit :
> From: Nicolas de Peslo=FCan<nicolas.2p.debian@gmail.com>
> Date: Wed, 25 Jul 2012 00:13:55 +0200
>
>> - From the af_packet point of view, is was "the real original device
>> - that received the packet".
>>
>> As bonding don't use orig_dev anymore, the remaining meaning should
>> logically be "the real original device that received the packet". Bu=
t
>> as __netif_receive_skb() is recursively called in many cases, settin=
g
>> orig_dev to something new every time, this meaning is probably mostl=
y
>> inconsistent. As such, it sounds appropriate to remove orig_dev and
>> use skb_iif instead.
>
> I don't think we can, otherwise people who set po->origdev will no
> longer get what they expect.
>
> For the simpler cases of bonding and VLANs, it does currently behaved
> as expected.
>
> That's why I left it alone.

Do they get what they expect when stacking interfaces?

__netif_receive_skb starts with orig_dev =3D skb->dev. So when calling =
__netif_receive_skb=20
recursively, after changing skb->dev, they get the packet several times=
, with a different orig_dev=20
value?

Any way, both looks good to me.

	Nicolas.
