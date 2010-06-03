From: David =?iso-8859-1?Q?H=E4rdeman?= <david@hardeman.nu>
Subject: e1000e driver, Intel 82567LF-2, link negotiation (and wol) problems
Date: Fri, 4 Jun 2010 00:20:24 +0200
Message-ID: <20100603222024.GA22121@hardeman.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jesse.brandeburg@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-12-13a.han.sth.bostream.se ([82.182.30.168]:44524 "EHLO
	palpatine.hardeman.nu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510Ab0FCW1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 18:27:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have an Intel DG45FC motherboard with an integrated gigabit NIC (lspc=
i=20
says it's a "Intel Corporation 82567LF-2 Gigabit Network Connection").

When using the in-kernel e1000e driver (tried up to kernel version=20
2.6.34), the speed is negotiated to 100mbit (most of the time) even=20
though the NIC is connected to a gigabit switch using quality cables=20
(I've tried a few different to be sure).  There seems to be no real=20
pattern to when the link is negotiated to 100mbit or 1000mbit.

I've tried Intel's version of the driver (e1000e from sourceforge,=20
version 1.1.19) and it seems to behave in the same way.

The output from mii-tool is quite confusing:
scott:~# mii-tool -v eth0
SIOCGMIIREG on eth0 failed: Input/output error
SIOCGMIIREG on eth0 failed: Input/output error
eth0: negotiated 100baseTx-FD flow-control, link ok
  product info: vendor 00:50:43, model 11 rev 0
  basic mode:   autonegotiation enabled
  basic status: autonegotiation complete, link ok
  capabilities: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD=20
10baseT-HD
  advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD=20
flow-control
  link partner: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD=20
10baseT-HD flow-control

(capabilities and link partner agree on 1000mbit, but only 100mbit is=20
advertised according to mii-tool)

ethtool disagrees with mii-tool:
scott:~# ethtool eth0
Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 100baseT/Half=20
100baseT/Full 1000baseT/Full Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full 100baseT/Half=20
100baseT/Full 1000baseT/Full Advertised pause frame use: No
	Advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 2
	Transceiver: internal
	Auto-negotiation: on
	MDI-X: on
	Supports Wake-on: pumbag
	Wake-on: g
	Current message level: 0x00000001 (1)
	Link detected: yes

Manually setting the speed with ethtool doesn't work. Not sure how to=20
proceed...any suggestions?

(And while I'm at it, the Intel e1000e driver from sourceforge seems to=
=20
have a wol init bug, ethtool reports "Wake-on: g" but I can wake a=20
suspended machine using a simple ping. Calling "ethtool -s eth0 wol g"=20
before suspending gets the expected behaviour - i.e. only wake on a=20
magic wol packet. Don't want to register on sourceforge just to report=20
that to the bug tracker though).

Not subscribed to netdev, please CC me on any answers.

--=20
David H=E4rdeman
