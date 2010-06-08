From: David =?iso-8859-1?Q?H=E4rdeman?= <david@hardeman.nu>
Subject: Re: e1000e driver, Intel 82567LF-2, link negotiation (and wol)
 problems
Date: Tue, 8 Jun 2010 19:36:28 +0200
Message-ID: <20100608173628.GA5181@hardeman.nu>
References: <20100603222024.GA22121@hardeman.nu>
 <AANLkTikLgAsAQ-LmWOX9CTZHwVl7h7-ii4omnyHH79Al@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: John Ronciak <john.ronciak@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-12-13a.han.sth.bostream.se ([82.182.30.168]:46105 "EHLO
	palpatine.hardeman.nu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755306Ab0FHRgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 13:36:32 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTikLgAsAQ-LmWOX9CTZHwVl7h7-ii4omnyHH79Al@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 03, 2010 at 03:39:24PM -0700, John Ronciak wrote:
> On Thu, Jun 3, 2010 at 3:20 PM, David H=E4rdeman <david@hardeman.nu> =
wrote:
> > I have an Intel DG45FC motherboard with an integrated gigabit NIC (=
lspci
> > says it's a "Intel Corporation 82567LF-2 Gigabit Network Connection=
").
> >
> > When using the in-kernel e1000e driver (tried up to kernel version
> > 2.6.34), the speed is negotiated to 100mbit (most of the time) even
> > though the NIC is connected to a gigabit switch using quality cable=
s
> > (I've tried a few different to be sure). =A0There seems to be no re=
al
> > pattern to when the link is negotiated to 100mbit or 1000mbit.
> >
> > I've tried Intel's version of the driver (e1000e from sourceforge,
> > version 1.1.19) and it seems to behave in the same way.
> >
> > The output from mii-tool is quite confusing:
> > scott:~# mii-tool -v eth0
> > SIOCGMIIREG on eth0 failed: Input/output error
> > SIOCGMIIREG on eth0 failed: Input/output error
> > eth0: negotiated 100baseTx-FD flow-control, link ok
> > =A0product info: vendor 00:50:43, model 11 rev 0
> > =A0basic mode: =A0 autonegotiation enabled
> > =A0basic status: autonegotiation complete, link ok
> > =A0capabilities: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD
> > 10baseT-HD
> > =A0advertising: =A0100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
> > flow-control
> > =A0link partner: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD
> > 10baseT-HD flow-control
> >
> > (capabilities and link partner agree on 1000mbit, but only 100mbit =
is
> > advertised according to mii-tool)
> >
> > ethtool disagrees with mii-tool:
> > scott:~# ethtool eth0
> > Settings for eth0:
> > =A0 =A0 =A0 =A0Supported ports: [ TP ]
> > =A0 =A0 =A0 =A0Supported link modes: =A0 10baseT/Half 10baseT/Full =
100baseT/Half
> > 100baseT/Full 1000baseT/Full Supports auto-negotiation: Yes
> > =A0 =A0 =A0 =A0Advertised link modes: =A010baseT/Half 10baseT/Full =
100baseT/Half
> > 100baseT/Full 1000baseT/Full Advertised pause frame use: No
> > =A0 =A0 =A0 =A0Advertised auto-negotiation: Yes
> > =A0 =A0 =A0 =A0Speed: 100Mb/s
> > =A0 =A0 =A0 =A0Duplex: Full
> > =A0 =A0 =A0 =A0Port: Twisted Pair
> > =A0 =A0 =A0 =A0PHYAD: 2
> > =A0 =A0 =A0 =A0Transceiver: internal
> > =A0 =A0 =A0 =A0Auto-negotiation: on
> > =A0 =A0 =A0 =A0MDI-X: on
> > =A0 =A0 =A0 =A0Supports Wake-on: pumbag
> > =A0 =A0 =A0 =A0Wake-on: g
> > =A0 =A0 =A0 =A0Current message level: 0x00000001 (1)
> > =A0 =A0 =A0 =A0Link detected: yes
> >
> > Manually setting the speed with ethtool doesn't work. Not sure how =
to
> > proceed...any suggestions?
> >
> > (And while I'm at it, the Intel e1000e driver from sourceforge seem=
s to
> > have a wol init bug, ethtool reports "Wake-on: g" but I can wake a
> > suspended machine using a simple ping. Calling "ethtool -s eth0 wol=
 g"
> > before suspending gets the expected behaviour - i.e. only wake on a
> > magic wol packet. Don't want to register on sourceforge just to rep=
ort
> > that to the bug tracker though).
> >
> > Not subscribed to netdev, please CC me on any answers.
> >
> > --
> > David H=E4rdeman
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
> >
> What is your link partner? =20

A netgear gigabit switch

> Do different ones all do the same thing?

Haven't tried different ones yet, would have to lug hardware all over=20
the apartment to do so

> Is the link partner configured for auto-neg? =20

I guess so, switches should be?

> If you force speed and
> duplex to 1000/full on both sides, is it linked at 1000/full?=20

Can't force anything on the switch=20


> You have to force both sides of the connection for it to work=20
> correctly.
> Same for auto-neg, both sides need to be set to do that.  Maybe the
> link partner is only advertising 100Mb and so that is what it is
> linking to?

The switch *is* advertising 1000Mb, if I reboot the computer *or*=20
plug/unplug the cable, the NIC will negotiate 1000Mb about 1/3 of the=20
time. Also, the NIC seems to negotiate 1000Mb while the computer is=20
booting (during the BIOS phase, before the kernel takes over).

> --=20
> Cheers,
> John

Thanks for the feedback, any other suggestions?=20

--=20
David H=E4rdeman
