From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: tc class replace doesn't change =?UTF-8?Q?parent=3F?=
Date: Mon, 22 Apr 2013 02:03:50 +0300
Message-ID: <520880b2d790fd80e0f476bec52adfab@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:43197 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097Ab3DUXN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 19:13:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Just got probably bug, or maybe undocumented feature, that is easy to 
reproduce:

core7 ~ # tc qdisc replace dev eth0 root handle 1: htb
core7 ~ # tc class add dev eth0 classid 1:1 parent 1: htb rate 1Mbit 
ceil 1Mbit
core7 ~ # tc class show dev eth0
class htb 1:1 root prio 0 rate 1000Kbit ceil 1000Kbit burst 1600b 
cburst 1600b
core7 ~ # tc class replace dev eth0 classid 1:1 parent 1:2 htb rate 
1Mbit ceil 1Mbit
core7 ~ # tc class show dev eth0
class htb 1:1 root prio 0 rate 1000Kbit ceil 1000Kbit burst 1600b 
cburst 1600b

Note: parent didn't changed, while it should be changed, i think, since 
operation is not change, it is replace.

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
