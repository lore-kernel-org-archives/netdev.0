From: Ariel Elior <Ariel.Elior@qlogic.com>
Subject: RE: bnx2x - occasional high packet loss (on LAN)
Date: Wed, 16 Sep 2015 08:15:41 +0000
Message-ID: <81D78EA7F834FA4C83B64260D494C8590870F221@avmb3.qlogic.org>
References: <20150915041726.GD6850@pcnci.linuxbox.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "nik@linuxbox.cz" <nik@linuxbox.cz>
To: Nikola Ciprich <nikola.ciprich@linuxbox.cz>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:56448 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752498AbbIPIQF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2015 04:16:05 -0400
In-Reply-To: <20150915041726.GD6850@pcnci.linuxbox.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nikola,
Please provide dmesg output from your system.
Thanks,
Ariel

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
> Behalf Of Nikola Ciprich
> Sent: Tuesday, September 15, 2015 7:17 AM
> To: netdev <netdev@vger.kernel.org>
> Cc: nik@linuxbox.cz
> Subject: bnx2x - occasional high packet loss (on LAN)
> 
> Hello,
> 
> I'm trying to track strange issue with one of our servers and
> like to ask for recommendations..
> 
> I've got three node cluster (nodes A..C) interconnected with stacked broadcom
> ICX6610. eth0 of each box is connected to first switch, eth1 to second one,
> bonding set as follows: "mode=802.3ad lacp_rate=fast xmit_hash_policy=layer2+3
> miimon=100"
> 
> It happened few times, that suddenly eth1 on box A started misbehaving and
> communication
> with other nodes (ie flood ping) started dropping up to 30% packets. When this port
> has been shut on both sides, problem immediately vanished.
> 
> We've tried replacing card, cable and using different port on switch, but problem
> repeated again yesterday..
> 
> Since it's "only" loss, and not link loss, bonding doesn't help me much..
> 
> however during weekend, port also had strange link issue:
> 
> Sep 12 15:23:45 remrprv1a kernel: [676373.296786] bnx2x 0000:03:00.1 eth1: NIC
> Link is Down
> Sep 12 15:23:46 remrprv1a kernel: [676373.356638] bond0: link status definitely
> down for interface eth1, disabling it
> Sep 12 15:23:46 remrprv1a kernel: [676374.299571] bnx2x 0000:03:00.1 eth1: NIC
> Link is Up, 10000 Mbps full duplex, Flow control: ON - receive & transmit
> Sep 12 15:23:47 remrprv1a kernel: [676374.364428] bond0: link status definitely up
> for interface eth1, 10000 Mbps full duplex
> Sep 12 15:23:47 remrprv1a kernel: [676374.372902] bond0: first active interface up!
> Sep 12 15:24:24 remrprv1a kernel: [676411.402511] bnx2x 0000:03:00.1 eth1: NIC
> Link is Down
> Sep 12 15:24:24 remrprv1a kernel: [676411.407422] bond0: link status definitely
> down for interface eth1, disabling it
> Sep 12 15:24:25 remrprv1a kernel: [676412.405311] bnx2x 0000:03:00.1 eth1: NIC
> Link is Up, 10000 Mbps full duplex, Flow control: ON - receive & transmit
> Sep 12 15:24:25 remrprv1a kernel: [676412.408123] bond0: link status definitely up
> for interface eth1, 0 Mbps full duplex
> Sep 12 15:24:51 remrprv1a kernel: [676438.477641] bnx2x 0000:03:00.1 eth1: NIC
> Link is Down
> Sep 12 15:24:51 remrprv1a kernel: [676438.528513] bond0: link status definitely
> down for interface eth1, disabling it
> Sep 12 15:24:52 remrprv1a kernel: [676439.480472] bnx2x 0000:03:00.1 eth1: NIC
> Link is Up, 10000 Mbps full duplex, Flow control: ON - receive & transmit
> Sep 12 15:24:52 remrprv1a kernel: [676439.536282] bond0: link status definitely up
> for interface eth1, 10000 Mbps full duplex
> 
> 0mbps link speed is quite weird I guess..
> 
> all three boxes are the same, running centos6 based system, 4.0.5 x86_64 kernel.
> 
> The only difference I noticed on them is, that irqbalance was enabled on problematic
> box and not on the others.. So I disabled it and rebooted the box.. The problem is,
> I can't really wait for the problem to reappear, so I'd like to ask, has anybody
> seen similar problem? I of so, was it fixed in some newer kernel release? I haven't
> found mention in the changelogs, but still.. or does somebody have a hint on what
> else
> I should check?
> 
> I'll try to reproduce this on test system (enabling irqbalance and doing some network
> benchmarks, but I'd be most happy if I could prevent it on this production system..)
> 
> thanks a lot for any advance
> 
> with best regards
> 
> nikola ciprich
> 
> PS: here's lspci -vv of eths.. should I provide any further information, please let me
> know:
> 
> http://nik.lbox.cz/download/lspci.txt
> 
> --
> -------------------------------------
> Ing. Nikola CIPRICH
> LinuxBox.cz, s.r.o.
> 28.rijna 168, 709 00 Ostrava
> 
> tel.:   +420 591 166 214
> fax:    +420 596 621 273
> mobil:  +420 777 093 799
> www.linuxbox.cz
> 
> mobil servis: +420 737 238 656
> email servis: servis@linuxbox.cz
> -------------------------------------
