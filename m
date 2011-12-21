From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Wed, 21 Dec 2011 11:28:54 +0100
Message-ID: <1324463334.2728.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EF1B0D9.2010007@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:53683 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956Ab1LUK26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 05:28:58 -0500
Received: by vcbfk14 with SMTP id fk14so5604269vcb.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 02:28:57 -0800 (PST)
In-Reply-To: <4EF1B0D9.2010007@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 11:11 +0100, Michal Simek a =C3=
=A9crit :
> Hi Eric and David,
>=20
> I have found one problem with ll_temac driver and
> this commit: net: more accurate skb truesize
> sha1: 87fb4b7b533073eeeaed0b6bf7c2328995f6c075
>=20
> The problem is only with icmp packets from the target. It is sent and=
 driver receive it
> but it is not proceed to the application.
>=20
> The problem I see is that kmalloc_node_track_caller allocate
> specific size and then this size is changed by SKB_WITH_OVERHEAD(ksiz=
e(data)).
> The problem is with netdev_alloc_skb_ip_align which calls __alloc_skb=
 function.
>=20
> Currently driver uses setting for jumbo frames (9k). When I change it=
 to use mtu (1,5k) then
> everything is ok.
>=20
> Can you give me some hints what can be wrong?
>=20

Is it with SLUB, SLAB or SLOB allocator ?
