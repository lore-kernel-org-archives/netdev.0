From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: will 2 cpu simultaneously process packets which have same
 hash value on multiqueue nic?
Date: Thu, 20 May 2010 15:20:59 +0300
Message-ID: <1274358059.17395.11.camel@lb-tlvb-eilong.il.broadcom.com>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497F5B7D6@MILEXCH2.ds.jdsu.net>
 <1274355967.17395.5.camel@lb-tlvb-eilong.il.broadcom.com>
 <1274356826.4046.29.camel@edumazet-laptop>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Jon Zhou" <Jon.Zhou@jdsu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3956 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752058Ab0ETMVY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 08:21:24 -0400
In-Reply-To: <1274356826.4046.29.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-05-20 at 05:00 -0700, Eric Dumazet wrote:
> Le jeudi 20 mai 2010 =C3=A0 14:46 +0300, Eilon Greenstein a =C3=A9cri=
t :
> > On Wed, 2010-05-19 at 22:37 -0700, Jon Zhou wrote:
> > > will 2 cpu simultaneously  process packets which have same hash v=
alue on multiqueue nic?
> > >=20
> > > let 's take broadcom 57711 bnx2x_main.c as an example:
> > >=20
> > > #1 packet1->queue=3D1
> > > #2 packet2->queue=3D1
> > >=20
> > > will cpu1 and cpu2 execute the function " bnx2x_rx_int" in parall=
el, to receive packet1 & packet2
> > Both packets will be handled by the same queue and the queue proces=
sing
> > is serialized - so the packets will be handled one after the other.
>=20
> I am scratching my head to understand both the question and your
> answer...
>=20
I was trying to say that since both packets are handled on the same
queue - it is handled one after the other and not by two different CPUs
working on the same queue at once.

> if cpu1 is handling an interrupt, cpu2 cannot handle an interrupt at =
the
> same time for same queue. It must be for a different queue.
>=20
> Therefore, packets will be handled in parallel.
What do you mean "in parallel"? As you wrote above, only one cpu is
handling the packets from that queue, and since the hash is the same,
even RPS will not allow different CPUs to handle those 2 packets.

>=20
> Serialization might be done later, at socket layer to queue packets i=
n a
> receive queue for example, if both packets must be delivered on same
> socket.
Though this is always true, the case of receiving packets on the same
queue is even simpler, is not it?



