From: Ben Greear <greearb@candelatech.com>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Wed, 30 Jan 2008 11:17:15 -0800
Message-ID: <47A0CD3B.3050502@candelatech.com>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: Bruce Allen <ballen@gravity.phys.uwm.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:36140 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752997AbYA3TRe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 14:17:34 -0500
In-Reply-To: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bruce Allen wrote:
> (P=E1draig Brady has suggested that I post this to Netdev.  It was=20
> originally posted to LKML here: http://lkml.org/lkml/2008/1/30/141 )
>=20
>=20
> Dear NetDev,
>=20
> We've connected a pair of modern high-performance boxes with integrat=
ed=20
> copper Gb/s Intel NICS, with an ethernet crossover cable, and have ru=
n=20
> some netperf full duplex TCP tests.  The transfer rates are well belo=
w=20
> wire speed.  We're reporting this as a kernel bug, because we expect =
a=20
> vanilla kernel with default settings to give wire speed (or close to=20
> wire speed) performance in this case. We DO see wire speed in simplex=
=20
> transfers. The behavior has been verified on multiple machines with=20
> identical hardware.

Try using NICs in the pci-e slots.  We have better
luck there, as you usually have more lanes and/or higher
quality NIC chipsets available in this case.

Try a UDP test to make sure the NIC can actually handle the throughput.

Look at the actual link usage as reported by the ethernet driver so tha=
t you
take all of the ACKS and other overhead into account.

Try the same test using 10G hardware (CX4 NICs are quite affordable
these days, and we drove a 2-port 10G NIC based on the Intel ixgbe
chipset at around 4Gbps on two ports, full duplex, using pktgen).
As in around 16Gbps throughput across the busses.  That may also give y=
ou an idea
if the bottleneck is hardware or software related.

Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

