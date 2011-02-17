From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] bnx2x: Support for managing RX indirection table
Date: Thu, 17 Feb 2011 10:09:24 +0100
Message-ID: <1297933764.2670.20.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1102161210190.31937@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eilong@broadcom.com, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63835 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753887Ab1BQJJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 04:09:29 -0500
Received: by bwz15 with SMTP id 15so1468845bwz.19
        for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 01:09:28 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1102161210190.31937@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 16 f=C3=A9vrier 2011 =C3=A0 12:27 -0800, Tom Herbert a =C3=A9=
crit :
> Support fetching and retrieving RX indirection table via ethtool.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/bnx2x/bnx2x.h         |    2 +
>  drivers/net/bnx2x/bnx2x_ethtool.c |   56 +++++++++++++++++++++++++++=
++++++++++
>  drivers/net/bnx2x/bnx2x_main.c    |   22 +++++++++++---
>  3 files changed, 75 insertions(+), 5 deletions(-)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


As this is a bit unusual stuff (ethtool -X), I guess some hints can be
useful to testers and admins :

I tested this patch on my dev machine

Broadcom Corporation NetXtreme II BCM57711E 10Gigabit PCIe
(Hewlett-Packard Company NC532i Dual Port 10GbE Multifunction BL-C
Adapter)


# ethtool -X eth1 weight 0 1 0 2 0 4 0 8 0 16 0 32
# ethtool -x eth1=20
RX flow hash indirection table for eth1 with 16 RX ring(s):
    0:      1     1     3     3     3     3     5     5
    8:      5     5     5     5     5     5     7     7
   16:      7     7     7     7     7     7     7     7
   24:      7     7     7     7     7     7     9     9
   32:      9     9     9     9     9     9     9     9
   40:      9     9     9     9     9     9     9     9
   48:      9     9     9     9     9     9     9     9
   56:      9     9     9     9     9     9    11    11
   64:     11    11    11    11    11    11    11    11
   72:     11    11    11    11    11    11    11    11
   80:     11    11    11    11    11    11    11    11
   88:     11    11    11    11    11    11    11    11
   96:     11    11    11    11    11    11    11    11
  104:     11    11    11    11    11    11    11    11
  112:     11    11    11    11    11    11    11    11
  120:     11    11    11    11    11    11    11    11


After some (distributed) trafic on eth1 I get :

[root@svivoipvnx021 ~]# ethtool -S eth1|grep rx_ucast_packets
     [0]: rx_ucast_packets: 62
     [1]: rx_ucast_packets: 15870
     [2]: rx_ucast_packets: 9
     [3]: rx_ucast_packets: 31507
     [4]: rx_ucast_packets: 0
     [5]: rx_ucast_packets: 63106
     [6]: rx_ucast_packets: 0
     [7]: rx_ucast_packets: 122051
     [8]: rx_ucast_packets: 1
     [9]: rx_ucast_packets: 248071
     [10]: rx_ucast_packets: 0
     [11]: rx_ucast_packets: 519864
     [12]: rx_ucast_packets: 0
     [13]: rx_ucast_packets: 0
     [14]: rx_ucast_packets: 0
     [15]: rx_ucast_packets: 0
     rx_ucast_packets: 1000541


