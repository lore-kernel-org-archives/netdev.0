From: Jan Evert van Grootheest <j.e.van.grootheest@caiway.nl>
Subject: adm8211 (from linville wireless-2.6) in xen guest
Date: Sat, 20 Jan 2007 13:19:38 +0100
Message-ID: <45B208DA.8010807@caiway.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from cardassian.kabelfoon.nl ([62.45.45.18]:60659 "EHLO
	cardassian.kabelfoon.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965050AbXATMvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jan 2007 07:51:43 -0500
Received: from suzy2.janevert.homelinux.org (051-010-128-083.dynamic.caiway.nl [83.128.10.51])
	by cardassian.kabelfoon.nl (Postfix) with ESMTP id 99C05342311
	for <netdev@vger.kernel.org>; Sat, 20 Jan 2007 13:19:39 +0100 (CET)
Received: from lappie.janevert.homelinux.org ([192.168.1.115])
	by suzy2.janevert.homelinux.org with esmtp (Exim 4.63)
	(envelope-from <j.e.van.grootheest@caiway.nl>)
	id 1H8FC7-0003wU-GL
	for netdev@vger.kernel.org; Sat, 20 Jan 2007 13:19:39 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Just writing to thank all of you that made the adm8211 driver in John 
Linvilles wireless-2.6 development tree (not the dscape one, which I 
will try also).

It is this card:
00:01.0 Network controller: ADMtek ADM8211 802.11b Wireless Interface 
(rev 11)
        Subsystem: Standard Microsystems Corp [SMC] Unknown device 2602
        Flags: bus master, medium devsel, latency 96, IRQ 16
        I/O ports at d800 [size=256]
        Memory at cfffe400 (32-bit, non-prefetchable) [size=1K]
        Expansion ROM at <ignored> [disabled]
        Capabilities: [c0] Power Management version 2

which is reported by the driver as
Jan 16 22:05:40 janus kernel: adm8211: release 20060414
Jan 16 22:05:40 janus kernel: PCI: Enabling device 0000:00:01.0 (0000 -> 
0003)
Jan 16 22:05:40 janus kernel: 0000:00:01.0 (adm8211): EEPROM type 93C46
Jan 16 22:05:40 janus kernel: 0000:00:01.0 (adm8211): Channel range: 1 - 13
Jan 16 22:05:40 janus kernel: 0000:00:01.0 (adm8211): RFtype=1 BBPtype=1 
Specific BBP=0 Transceiver=0
Jan 16 22:05:40 janus kernel: eth0: hwaddr 00:04:e2:5e:b3:08, IRQ 16, 
Rev 0x11

I've taken two commits from that tree (the initial one and one about 
statistics) to make a driver that would compile against debian etch 
2.6.18 and moved the Makefile to be Kbuild. That allowed me to compile 
it as an external module (with something like 'make -C 
/lib/modules/2.6.18-xxxxxx/build M=/usr/src/wireless-adm8211 
CONFIG_ADM8211=m').
 
So I now have an AMD64 with xen on it. The adm8211 card is used in one 
of the guest domains!

One question, though. I'm trying to use it in ad-hoc mode. If there's no 
other station with the same essid, it just keeps mentioning that 
(besides the BCNTC and TSFTF messages)

wlan0: No matching adhoc sta found. Creating IBSS 00:04:e2:3f:2a:70 CHAN=11

And the IBSS changes every time, which is about every 30 seconds. Is it 
really supposed to change the IBSS each time?
The reason I ask is that my wife has a laptop with an Atheros chip in 
it. If it is configured for ad-hoc it creates the IBSS and sticks with 
it. So I now have two computers that have different behaviour in this 
respect. That in itself is not, I guess, a problem. But it seems to me 
that the random IBSS created by the adm8211 would result in two stations 
not seeing eachother or taking longer than necessary to find eachother?

And one more question that I don't understand... the wlan0 interface 
does not appear in snmp queries. Any idea about that?

Please CC me; I'm not subscribed.

Thanks,
Jan Evert

