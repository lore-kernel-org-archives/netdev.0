From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: AW: AW: RFC: replace packets already in queue
Date: Mon, 02 Jul 2012 23:56:08 +0200
Message-ID: <1341266168.22621.466.camel@edumazet-glaptop>
References: <FB112703C4930F4ABEBB5B763F96491139378722@MAILSERV2A.lorien.fkie.fgan.de>
	 <4FEC854E.8080603@hp.com>
	 <FB112703C4930F4ABEBB5B763F96491139378E5A@MAILSERV2A.lorien.fkie.fgan.de>
	 <1340960817.15719.6.camel@edumazet-glaptop>
	 <FB112703C4930F4ABEBB5B763F964911393795D6@MAILSERV2A.lorien.fkie.fgan.de>
	 <1341214310.5269.27.camel@edumazet-glaptop>
	 <FB112703C4930F4ABEBB5B763F96491139379643@MAILSERV2A.lorien.fkie.fgan.de>
	 <4FF20557.4090501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Erdt, Ralph" <ralph.erdt@fkie.fraunhofer.de>,
	Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:64042 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118Ab2GBV4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 17:56:15 -0400
Received: by wgbdr13 with SMTP id dr13so5643022wgb.1
        for <netdev@vger.kernel.org>; Mon, 02 Jul 2012 14:56:14 -0700 (PDT)
In-Reply-To: <4FF20557.4090501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-02 at 22:32 +0200, Nicolas de Peslo=C3=BCan wrote:
> Le 02/07/2012 10:38, Erdt, Ralph a =C3=A9crit :
> >>> Even if the wireless queue is a problem (because of our setup, th=
is
> >> is
> >>> not a problem), the network stack queue (*) is the biggest queue,=
 and
> >>> a good point to optimize.
> >>
> >> Hmm, I am not convinced you have no queues on wireless.
> >>
> >> Please describe how you managed this.
> >>
> >> In fact this is the biggest problem with wireless : mac82011 frame=
work
> >> aggressively pull packets from Linux packet qdisc in order to perf=
orm
> >> packet aggregation.
> >
> > I did not talking about W-LAN (802.11). I'm talking about an proper=
ty technology which is able to
> > send over KILOMETERs (WLAN<  100m) but with VERY low bandwidth: 960=
0 bit (no Mega, Giga or Kilo!)
> > (W-LAN: slowest: 1Mbit). The devices is loosely connected to our bo=
xes: No linux driver but a
> > program which create an virtual network device. This just sends one=
 packet to the devices and
> > then waits for the acknowledgement that the packet was sent. THEN t=
he next packet will be send.
> > There is no further queue, because the wireless is so lame, that th=
ere is no need for that! (BTW:
> > the qdisc and the connector are distinct problems/programs. There i=
s no dependency.)
>=20
> If I were you, I would use a tun/tap interface and manage a private p=
acket queue in userspace. This=20
> way, you wouldn't have to manage the overhead of porting your kernel =
code to every new kernel versions.
>=20

This seems a good idea.

Then you can do other coalescing stuff, like TCP ACK that could be
aggregated to single ACK as well.
