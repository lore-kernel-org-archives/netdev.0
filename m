From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2] tcp: fix crash in tcp_xmit_retransmit_queue
Date: Mon, 19 Jul 2010 19:39:08 +0200
Message-ID: <1279561148.2553.150.camel@edumazet-laptop>
References: <4C358AAA.9080400@kernel.org>
	 <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi>
	 <4C3EF7EA.2040900@nets.rwth-aachen.de>
	 <1279195528.2496.2.camel@edumazet-laptop>
	 <4C3F053F.7090704@nets.rwth-aachen.de>
	 <alpine.DEB.2.00.1007161448330.13946@melkinpaasi.cs.helsinki.fi>
	 <4C404FC5.6040107@nets.rwth-aachen.de>
	 <alpine.DEB.2.00.1007161602510.13946@melkinpaasi.cs.helsinki.fi>
	 <4C440771.7080107@nets.rwth-aachen.de>
	 <alpine.DEB.2.00.1007191319010.13002@wel-95.cs.helsinki.fi>
	 <1279548555.2553.51.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1007192013010.30181@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1007192013010.30181@melkinpaasi.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 19 juillet 2010 =C3=A0 20:25 +0300, Ilpo J=C3=A4rvinen a =C3=A9=
crit :

> This difference is well thought and intentional, I didn't use differe=
nt=20
> one by accident. We want to make sure we won't use NULL from=20
> tcp_write_queue_head() while the pre 08ebd1721ab8fd3 kernels was=20
> interested mainly whether the first loop should run or not (and of co=
urse=20
> ends up avoid the null deref too but it's more optimization like=20
> thing in there, ie., if there's no lost packets no work to-do). The d=
eref=20
> could have been fixed by moving TCP_SKB_CB(skb)->sacked a bit later b=
ut=20
> that would again make us depend on the side-effect of the send_head c=
heck=20
> (in the case of packets_out being zero and wq empty) which is somethi=
ng I=20
> don't like too much.
>=20

Thanks Ilpo.

Do you know in what exact circumstance the bug triggers ?

It's hard to believe thousand of machines on the Internet never hit
it :(

Maybe another problem in congestion control ?
