From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: ixgbe question
Date: Mon, 23 Nov 2009 15:28:18 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0911231525180.10056@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>
 <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com>
 <1258968980.2697.9.camel@ppwaskie-mobl2> <4B0A6218.9040303@gmail.com>
 <Pine.LNX.4.64.0911231500060.24347@ask.diku.dk> <4B0A9E4E.9010804@gmail.com>
 <19210.54486.353397.804028@gargle.gargle.HOWL> <4B0ABF6D.9000103@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="220046-25034-1259018898=:10056"
Cc: "robert@herjulf.net" <robert@herjulf.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36383 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932123AbZKWX2J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 18:28:09 -0500
In-Reply-To: <4B0ABF6D.9000103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--220046-25034-1259018898=:10056
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 23 Nov 2009, Eric Dumazet wrote:

> robert@herjulf.net a =E9crit :
> > Eric Dumazet writes:
> >=20
> >  > Jesper Dangaard Brouer a =E9crit :
> >  >=20
> >  > > How is your smp_affinity mask's set?
> >  > >=20
> >  > > grep . /proc/irq/*/fiber1-*/../smp_affinity
> >  >=20
> >=20
> >  Weird... set clone_skb to 1 to be sure and vary dst or something so=20
> >  the HW classifier selects different queues and with proper RX affinty.=
=20
> > =20
> >  You should see in /proc/net/softnet_stat something like:
> >=20
> > 012a7bb9 00000000 000000ae 00000000 00000000 00000000 00000000 00000000=
 00000000
> > 01288d4c 00000000 00000049 00000000 00000000 00000000 00000000 00000000=
 00000000
> > 0128fe28 00000000 00000043 00000000 00000000 00000000 00000000 00000000=
 00000000
> > 01295387 00000000 00000047 00000000 00000000 00000000 00000000 00000000=
 00000000
> > 0129a722 00000000 0000004a 00000000 00000000 00000000 00000000 00000000=
 00000000
> > 0128c5e4 00000000 00000046 00000000 00000000 00000000 00000000 00000000=
 00000000
> > 0128f718 00000000 00000043 00000000 00000000 00000000 00000000 00000000=
 00000000
> > 012993e3 00000000 0000004a 00000000 00000000 00000000 00000000 00000000=
 00000000
> >=20
>=20
> slone_skb set to 1, this changes nothing but slows down pktgen (obviously=
)
>=20
> Result: OK: 117614452(c117608705+d5746) nsec, 100000000 (60byte,0frags)
>   850235pps 408Mb/sec (408112800bps) errors: 0
>=20
> All RX processing of 16 RX queues done by CPU 1 only.

Ok, I was confused earlier.  I thought you were saying that all packets=20
were headed into a single Rx queue.  This is different.

Do you know what version of irqbalance you're running, or if it's running=
=20
at all?  We've seen issues with irqbalance where it won't recognize the=20
ethernet device if the driver has been reloaded.  In that case, it won't=20
balance the interrupts at all.  If the default affinity was set to one=20
CPU, then well, you're screwed.

My suggestion in this case is after you reload ixgbe and start your tests,=
=20
see if it all goes to one CPU.  If it does, then restart irqbalance=20
(service irqbalance restart - or just kill it and restart by hand).  Then=
=20
start running your test, and in 10 seconds you should see the interrupts=20
move and spread out.

Let me know if this helps,
-PJ
--220046-25034-1259018898=:10056--
