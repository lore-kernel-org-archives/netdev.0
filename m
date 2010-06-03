From: John Ronciak <john.ronciak@gmail.com>
Subject: Re: e1000e driver, Intel 82567LF-2, link negotiation (and wol)
	problems
Date: Thu, 3 Jun 2010 15:39:24 -0700
Message-ID: <AANLkTikLgAsAQ-LmWOX9CTZHwVl7h7-ii4omnyHH79Al@mail.gmail.com>
References: <20100603222024.GA22121@hardeman.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: =?ISO-8859-1?Q?David_H=E4rdeman?= <david@hardeman.nu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f223.google.com ([209.85.219.223]:38042 "EHLO
	mail-ew0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754819Ab0FCWj0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 18:39:26 -0400
Received: by ewy23 with SMTP id 23so159882ewy.1
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 15:39:25 -0700 (PDT)
In-Reply-To: <20100603222024.GA22121@hardeman.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 3, 2010 at 3:20 PM, David H=E4rdeman <david@hardeman.nu> wr=
ote:
> I have an Intel DG45FC motherboard with an integrated gigabit NIC (ls=
pci
> says it's a "Intel Corporation 82567LF-2 Gigabit Network Connection")=
=2E
>
> When using the in-kernel e1000e driver (tried up to kernel version
> 2.6.34), the speed is negotiated to 100mbit (most of the time) even
> though the NIC is connected to a gigabit switch using quality cables
> (I've tried a few different to be sure). =A0There seems to be no real
> pattern to when the link is negotiated to 100mbit or 1000mbit.
>
> I've tried Intel's version of the driver (e1000e from sourceforge,
> version 1.1.19) and it seems to behave in the same way.
>
> The output from mii-tool is quite confusing:
> scott:~# mii-tool -v eth0
> SIOCGMIIREG on eth0 failed: Input/output error
> SIOCGMIIREG on eth0 failed: Input/output error
> eth0: negotiated 100baseTx-FD flow-control, link ok
> =A0product info: vendor 00:50:43, model 11 rev 0
> =A0basic mode: =A0 autonegotiation enabled
> =A0basic status: autonegotiation complete, link ok
> =A0capabilities: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD
> 10baseT-HD
> =A0advertising: =A0100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
> flow-control
> =A0link partner: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD
> 10baseT-HD flow-control
>
> (capabilities and link partner agree on 1000mbit, but only 100mbit is
> advertised according to mii-tool)
>
> ethtool disagrees with mii-tool:
> scott:~# ethtool eth0
> Settings for eth0:
> =A0 =A0 =A0 =A0Supported ports: [ TP ]
> =A0 =A0 =A0 =A0Supported link modes: =A0 10baseT/Half 10baseT/Full 10=
0baseT/Half
> 100baseT/Full 1000baseT/Full Supports auto-negotiation: Yes
> =A0 =A0 =A0 =A0Advertised link modes: =A010baseT/Half 10baseT/Full 10=
0baseT/Half
> 100baseT/Full 1000baseT/Full Advertised pause frame use: No
> =A0 =A0 =A0 =A0Advertised auto-negotiation: Yes
> =A0 =A0 =A0 =A0Speed: 100Mb/s
> =A0 =A0 =A0 =A0Duplex: Full
> =A0 =A0 =A0 =A0Port: Twisted Pair
> =A0 =A0 =A0 =A0PHYAD: 2
> =A0 =A0 =A0 =A0Transceiver: internal
> =A0 =A0 =A0 =A0Auto-negotiation: on
> =A0 =A0 =A0 =A0MDI-X: on
> =A0 =A0 =A0 =A0Supports Wake-on: pumbag
> =A0 =A0 =A0 =A0Wake-on: g
> =A0 =A0 =A0 =A0Current message level: 0x00000001 (1)
> =A0 =A0 =A0 =A0Link detected: yes
>
> Manually setting the speed with ethtool doesn't work. Not sure how to
> proceed...any suggestions?
>
> (And while I'm at it, the Intel e1000e driver from sourceforge seems =
to
> have a wol init bug, ethtool reports "Wake-on: g" but I can wake a
> suspended machine using a simple ping. Calling "ethtool -s eth0 wol g=
"
> before suspending gets the expected behaviour - i.e. only wake on a
> magic wol packet. Don't want to register on sourceforge just to repor=
t
> that to the bug tracker though).
>
> Not subscribed to netdev, please CC me on any answers.
>
> --
> David H=E4rdeman
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
What is your link partner?  Do different ones all do the same thing?
Is the link partner configured for auto-neg?  If you force speed and
duplex to 1000/full on both sides, is it linked at 1000/full?  You
have to force both sides of the connection for it to work correctly.
Same for auto-neg, both sides need to be set to do that.  Maybe the
link partner is only advertising 100Mb and so that is what it is
linking to?


--=20
Cheers,
John
