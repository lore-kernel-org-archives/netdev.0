From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ehea: Fix a checksum issue on the receive path
Date: Fri, 08 Oct 2010 16:36:17 +0200
Message-ID: <1286548577.2959.412.camel@edumazet-laptop>
References: <1286493453-21784-1-git-send-email-leitao@linux.vnet.ibm.com>
	 <1286513130.6536.467.camel@edumazet-laptop>
	 <4CAF2732.90703@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47733 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757503Ab0JHOgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 10:36:23 -0400
Received: by wyb28 with SMTP id 28so1147386wyb.19
        for <netdev@vger.kernel.org>; Fri, 08 Oct 2010 07:36:22 -0700 (PDT)
In-Reply-To: <4CAF2732.90703@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 08 octobre 2010 =C3=A0 11:14 -0300, Breno Leitao a =C3=A9cr=
it :
> Hi Eric
>=20
> On 10/08/2010 01:45 AM, Eric Dumazet wrote:
> > Just to be clear : packets with wrong checksums are not given to up=
per
> > stack, so a tcpdump can not display them ? I am not sure many drive=
rs do
> > that.
> Well, what my code does is: 1) if the current packet is a UDP/TCP, th=
en=20
> the checksum is not necessary, since we would check the checksum on=20
> ehea_proc_rwqes(), specific at this part of the code:
>=20
>                 if (!ehea_check_cqe(cqe, &rq)) {
> 			// Send the packet to the up layers
>=20
> And ehea_check_cqe() checks for wrong checksumed packets on:
> =09
>          if ((cqe->status & EHEA_CQE_STAT_ERR_MASK) =3D=3D 0)
>                  return 0;
>=20
>=20
> Botton line, TCP/UDP packets with wrong checksums are dropped by=20
> ehea_proc_rwqes(), others go to the up layer.
>=20
> So, back to your question, you are saying that we shouldn't do that,=20
> meaning that we should send to the upper layers all packets ? even th=
ose=20
> that have the wrong checksum ?
>=20

I am pretty sure most (if not all) netdev drivers pass the packet with
invalid checksum to upper stack, so that we can increment appropriate
SNMP counters, in IP stack or UDP/TCP/whatever stack.

tg3, bnx2, e1000, skge, sky2, bnx2x, niu, r8169, igb, ... seems to do
that.



