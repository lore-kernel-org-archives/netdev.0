From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Wed, 21 Dec 2011 11:45:08 +0100
Message-ID: <1324464308.2728.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EF1B0D9.2010007@monstr.eu>
			 <1324463334.2728.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
		 <1324463452.2728.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
		 <4EF1B5BC.5020103@monstr.eu>
	 <1324463838.2728.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1B7E4.4010602@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:47388 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390Ab1LUKpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 05:45:11 -0500
Received: by vcbfk14 with SMTP id fk14so5614685vcb.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 02:45:11 -0800 (PST)
In-Reply-To: <4EF1B7E4.4010602@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 11:41 +0100, Michal Simek a =C3=
=A9crit :

> yes, page size is 4k.
>=20
> Here is the log for allocation - origin size for MTU 9000 is 0x2420(9=
248) and size after
> overhead is 0x3f40(16192)
>=20
> kmalloc_node_track_caller size 00002420, SKB_WITH_OVERHEAD(ksize(data=
)) 00003f40
> skb->head     c7870000
> skb->data     c7870000
> skb->tail     c7870000
> skb->truesize 000040c0
> skb->end      c7873f40
>=20

So basically truesize is bigger than previous kernel, and you hit a
socket limit.  (RCVBUF ?)

truesize is more correct, so we uncover prior bugs.

We should allow at least one packet, regardless of its size :(
