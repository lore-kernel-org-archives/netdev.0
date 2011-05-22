From: =?ISO-8859-1?Q?Ortwin_Gl=FCck?= <odi@odi.ch>
Subject: is UDP broadcast over wlan broken?
Date: Sun, 22 May 2011 16:30:46 +0200
Message-ID: <4DD91E16.1070300@odi.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fep22.mx.upcmail.net ([62.179.121.42]:50783 "EHLO
	fep22.mx.upcmail.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755133Ab1EVOlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 10:41:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 2.6.38.6 I can no longer receive UDP broadcasts over wireless interfaces.
This affects CUPS zeroconf (port 631 broadcasts). Other UDP traffic (like DNS
lookups) works fine.

I can see UDP broadcasts originate fine on 192.168.111.11/24 (my router):
# uname -a
Linux gandalf 2.6.38.6 #11 SMP PREEMPT Tue May 10 13:42:44 CEST 2011 x86_64
Intel(R) Core(TM) i3 CPU 540 @ 3.07GHz GenuineIntel GNU/Linux
# tcpdump -np -i wlan0 udp and port 631
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on wlan0, link-type EN10MB (Ethernet), capture size 96 bytes
16:15:21.695230 IP 192.168.111.11.631 > 192.168.111.255.631: UDP, length 151


But these packets are not received on 192.168.111.10/24 (the client):
# uname -a
Linux mithril 2.6.39 #2 SMP PREEMPT Sun May 22 14:22:23 CEST 2011 i686 Intel(R)
Core(TM)2 CPU T7600 @ 2.33GHz GenuineIntel GNU/Linux
# tcpdump -n -i wlan0 udp and port 631
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on wlan0, link-type EN10MB (Ethernet), capture size 96 bytes
^C
0 packets captured
0 packets received by filter
0 packets dropped by kernel

I made very sure that nothing is dropped by netfilter on either side.
Both sides use ath9k as their wifi driver.

Ortwin
