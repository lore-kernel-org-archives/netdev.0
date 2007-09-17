From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000 driver and samba
Date: Mon, 17 Sep 2007 10:02:51 -0700
Message-ID: <46EEB33B.6030305@intel.com>
References: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>	 <46EAC25B.2060404@intel.com>	 <780b6f780709141140l1fd586c9p2aa8efe6ed803d38@mail.gmail.com>	 <46EAF644.1040006@intel.com> <46EC1A00.2000304@katalix.com>	 <46EC2D5A.7080504@intel.com>	 <780b6f780709152106q3d7f1042t72126c1be16ed1fd@mail.gmail.com>	 <46ECB95F.2090100@intel.com> <780b6f780709170942h48df5eb4g5f3d19cdf5ef60de@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
To: L F <lfabio.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:3847 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752691AbXIQRDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 13:03:00 -0400
In-Reply-To: <780b6f780709170942h48df5eb4g5f3d19cdf5ef60de@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

L F wrote:
>> To me it suggests that your speed is not full-duplex. Check `ethtool eth0` output
>> and see if your link is full duplex or not. also check previous kernel messages
>> and see what the e1000 driver posted there for link speed messages (as in "e1000:
>>  Link is UP speed XXX duplex YYY")
> from dmesg:
> device eth4 entered promiscuous mode
> e1000: eth4: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex,
> Flow Control: RX/TX
> [It looks like the e1000 driver that came in the kernel is Intel(R)
> PRO/1000 Network Driver - version 7.3.20-k2 - would there be any
> benefit to trying the 7.6.5 from the Intel website again?]
> 
> from ethtool:
> beehive:~# ethtool eth4
> Settings for eth4:
>         Supported ports: [ TP ]
>         Supported link modes:   10baseT/Half 10baseT/Full
>                                 100baseT/Half 100baseT/Full
>                                 1000baseT/Full
>         Supports auto-negotiation: Yes
>         Advertised link modes:  10baseT/Half 10baseT/Full
>                                 100baseT/Half 100baseT/Full
>                                 1000baseT/Full
>         Advertised auto-negotiation: Yes
>         Speed: 1000Mb/s
>         Duplex: Full
>         Port: Twisted Pair
>         PHYAD: 0
>         Transceiver: internal
>         Auto-negotiation: on
>         Supports Wake-on: d
>         Wake-on: d
>         Current message level: 0x00000007 (7)
>         Link detected: yes
> 
> As best I can tell, the card is in full duplex mode.
> Because of a 'running out of ideas' compulsion I disassembled and
> reassembled the machine completely, ran a memory test overnight,
> changed the cable AGAIN with a CAT6 of the shortest possible length.

The statistic we were looking at _will_ increase when running in half duplex,
but if it increases when running in full duplex might indicate a hardware
failure. Probably you have fixed the issue with the CAT6 cable.

Can you run this new configuration with the old cable? that would eliminate
the cable (or not)

> That plus samba-3.0.26-1 seem to have cured the disconnects - as a
> matter of fact I CAN'T get the machine to disconnect anymore, even
> under completely artificial loads (i.e. stress test quality, not
> average use) from five clients (I know, that isn't saying much, but it
> was failing spectacularly at ONE before, so I figure this may be worth
> mentioning).
> However, the incorrect file transfer still occurs with large files
> (500MB+). My original thought behind the disassembly/reassembly/memory
> test was that possibly the issue was hardware related, but I seem to
> have eliminated that possiblity.
> Further, I checked. There are currently 20+ machines in production
> with the same debian distribution and kernel, running on 975X / P965
> boards, all with r8169 drivers, doing RAID5 fileserver duty. They
> work. With significant numbers (up to 65) of clients. This one doesn't
> want to. I can't help but think it's the NIC/driver combo, but it
> seems absurd to me.

A single port failure on a switch can also happen, and samba is definately
a good test for defective hardware. I cannot rule out anything from the
information we have gotten yet.

Auke
