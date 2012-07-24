From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH 2/2] ipv4: Change rt->rt_iif encoding.
Date: Wed, 25 Jul 2012 00:13:55 +0200
Message-ID: <500F1E23.7090803@gmail.com>
References: <20120723.152220.822947775372843073.davem@davemloft.net> <alpine.LFD.2.00.1207240157120.2404@ja.ssi.bg> <20120723.160541.184307938805782289.davem@davemloft.net> <20120723.161446.36265037346365173.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:44291 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754693Ab2GXWMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 18:12:47 -0400
Received: by wibhm11 with SMTP id hm11so4585102wib.1
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 15:12:45 -0700 (PDT)
In-Reply-To: <20120723.161446.36265037346365173.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/07/2012 01:14, David Miller a =E9crit :
[...]
> I wonder if we should just get rid of all of that orig_dev logic and
> simply update skb->skb_iif every time we hit the code starting at
> label "another_round"

It clearly depends on the exact meaning of orig_dev.

When we studied the usage of orig_dev before removing it from bonding, =
it was clear that two=20
different meanings existed:

- From the bonding point of view, is was "the device one level below cu=
rrent device" (the slave,=20
from the master's point of view).

- From the af_packet point of view, is was "the real original device th=
at received the packet".

As bonding don't use orig_dev anymore, the remaining meaning should log=
ically be "the real original=20
device that received the packet". But as __netif_receive_skb() is recur=
sively called in many cases,=20
setting orig_dev to something new every time, this meaning is probably =
mostly inconsistent. As such,=20
it sounds appropriate to remove orig_dev and use skb_iif instead.

	Nicolas.
