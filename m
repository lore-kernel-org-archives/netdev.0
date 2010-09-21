From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] qlcnic: dont assume NET_IP_ALIGN is 2
Date: Tue, 21 Sep 2010 10:34:33 +0200
Message-ID: <1285058073.2617.73.camel@edumazet-laptop>
References: <1284700483-16397-2-git-send-email-amit.salecha@qlogic.com>
	 <1284717448.3391.75.camel@edumazet-laptop>
	 <99737F4847ED0A48AECC9F4A1974A4B80F86F8018D@MNEXMB2.qlogic.org>
	 <20100920.085857.98907191.davem@davemloft.net>
	 <99737F4847ED0A48AECC9F4A1974A4B80F86F80270@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37344 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756446Ab0IUIek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 04:34:40 -0400
Received: by wyf22 with SMTP id 22so5163628wyf.19
        for <netdev@vger.kernel.org>; Tue, 21 Sep 2010 01:34:38 -0700 (PDT)
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80F86F80270@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 septembre 2010 =C3=A0 03:19 -0500, Amit Salecha a =C3=A9cri=
t :
>=20
> > -----Original Message-----
> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: Monday, September 20, 2010 9:29 PM
> > To: Amit Salecha
> > Cc: eric.dumazet@gmail.com; netdev@vger.kernel.org; Ameen Rahman;
> > Anirban Chakraborty
> > Subject: Re: [PATCH] qlcnic: dont assume NET_IP_ALIGN is 2
> >=20
> > From: Amit Salecha <amit.salecha@qlogic.com>
> > Date: Mon, 20 Sep 2010 06:16:31 -0500
> >=20
> > > Though I have one doubt. We are allocating larger packets than th=
e
> > actual data used.
> > > Doesn't it will break accounting ?
> >=20
> > No, it will "fix" accounting.
> >=20
> > You must charge to the SKB all of the non-shared memory that was
> > allocated to the SKB.
> >=20
> > This means even if the packet only uses 128 bytes of the SKB
> > data area, you must still account for the full blob of linear
> > memory that was allocated for the SKB data area in skb->truesize.
> >=20
> > Otherwise remote attackers could consume enormous amounts of memory=
 by
> > tricking our socket accounting via carefully sized packets.
>=20
> Wont this affect throughput ?
> As problem discuss in this thread http://www.mail-archive.com/netdev@=
vger.kernel.org/msg06848.html, it can affect tcp window scaling.
>=20

Amit, if you believe this is a problem, you should address it for all
NICS, not only qlcnic.

Qlcnic was lying to stack, because it consumed 2Kbytes blocs and
pretended they were consuming skb->len bytes.
(assuming MTU=3D1500, problem is worse if MTU is bigger)

So in order to improve "throughput", you were allowing for memory
exhaust and freeze of the _machine_ ?



