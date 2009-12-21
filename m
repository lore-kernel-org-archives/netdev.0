From: Hinko Kocevar <hinko.kocevar@i-tech.si>
Subject: Asus NX1001 (ipg driver) jumbo frames
Date: Mon, 21 Dec 2009 13:07:37 +0100
Message-ID: <4B2F6509.9030003@i-tech.si>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.i-tech.si ([89.212.78.105]:59114 "EHLO mail.i-tech.si"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751346AbZLUMWw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Dec 2009 07:22:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm using Gentoo based Linux version 2.6.31 from Gentoo portage.
I've recently added Asus NX1001 PCI Gigabit network card to my system.
The card is recognized and driver ipg for Linux is used. Since I want to
used jumbo frames, I set the MTU (using ifconfig) to 9000 bytes with
success.

When the remote site is sending a jumbo frame, wireshark sitting on my
Asus 1001 Gbe is not showing any packets. But, I can see that 'Rx bytes'
value in ifconfig eth1 has incremented appropriately.

Example:
1. receiving side, no packet yet sent from the transmitting side:
support-pc support # ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 00:22:15:10:b8:48
          inet addr:192.168.1.1  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: fe80::222:15ff:fe10:b848/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:7200  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:588 (588.0 B)
          Interrupt:21

2. one jumbo frame is received (wireshark shows nothing)
3. receiving side, one packet seen only in Rx bytes lines:
support-pc support # ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 00:22:15:10:b8:48
          inet addr:192.168.1.1  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: fe80::222:15ff:fe10:b848/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:7200  Metric:1
          RX packets:1 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:6140 (5.9 KiB)  TX bytes:588 (588.0 B)
          Interrupt:21


I see that there has been some MTU code changes in the past (2.6.26).

Can anyone confirm that jumbo frames are working on ipg driver in recent
kernels (2.6.31)? Are there any known issues with this driver?

I can also confirm, that remote side is working as expected (in regard
to jumbo frames) because I've tested another Gigabit NIC (using r8169
driver) - whose MTU can be set to only 7200 bytes.

Best regards,
Hinko

-- 
Hinko Kocevar
Technical support software engineer
Instrumentation Technologies
Velika pot 22, SI-5250 Solkan - Slovenia
T:+386 5 3352600, F:+386 5 3352601
mailto: hinko.kocevar@i-tech.si

http://www.i-tech.si - When your users demand stability

The information transmitted is intended solely for the addressee and may
contain confidential and/or privileged information. Any review, retention,
disclosure or other use by persons other than the intended recipient is
prohibited. If you received this in error, please notify the sender and
delete all copies.


