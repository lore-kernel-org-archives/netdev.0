From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: Incorrect ARP behavior when multiple/none IPv4 address assigned to
 interface
Date: Tue, 23 Oct 2012 14:28:17 +0300
Message-ID: <50867F51.3030500@mail.ru>
Reply-To: Sergey Popovich <popovich_sergei@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback3.mail.ru ([94.100.176.58]:42445 "EHLO
	fallback3.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440Ab2JWLfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 07:35:42 -0400
Received: from smtp15.mail.ru (smtp15.mail.ru [94.100.176.133])
	by fallback3.mail.ru (mPOP.Fallback_MX) with ESMTP id 2F86EC3C5505
	for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 15:28:55 +0400 (MSK)
Received: from [195.234.68.4] (port=33347 helo=tuxracer.localdomain)
	by smtp15.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1TQcev-00031h-Cs
	for netdev@vger.kernel.org; Tue, 23 Oct 2012 15:28:33 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

We have following setup:
------------------------

  PC1              |             |
   ip: 10.0.1.2/24 |             | Linux Router (3.7-rc2)
   gw: 10.0.1.1    |--------eth0-| Lo0: 10.10.10.10/32
                                 | Lo255: 10.0.1.1/24
  PC2              |--------eth1-|        10.0.2.1/24
   ip: 10.0.1.3/24 |             | eth[0-2]: no ip address
   gw: 10.0.1.1    |             | ip route 10.0.1.2/32 dev eth0 src 10.0.1.1
                               +-| ip route 10.0.1.3/32 dev eth1 src 10.0.1.1
                               | | ip route 10.0.2.2/32 dev eth2 src 10.0.2.1
  PC3              |-----eth2--+
   ip: 10.0.2.2/24 |
   gw: 10.0.2.1    |


Problem with ARP Requests sent with incorrect source address 
(10.10.10.10 instead of 10.0.1.1):

# tcpdump -vv -ieth0 -s1500 -nnpe 'arp'
13:28:57.395181 08:00:27:3b:63:ae > 0a:00:27:00:00:00, ethertype ARP 
(0x0806), length 42: Ethernet (len 6),.
IPv4 (len 4), Request who-has 10.0.1.2 tell 10.10.10.10, length 28
13:28:58.395257 08:00:27:3b:63:ae > 0a:00:27:00:00:00, ethertype ARP 
(0x0806), length 42: Ethernet (len 6),.
IPv4 (len 4), Request who-has 10.0.1.2 tell 10.10.10.10, length 28
13:28:59.395207 08:00:27:3b:63:ae > 0a:00:27:00:00:00, ethertype ARP 
(0x0806), length 42: Ethernet (len 6),.
IPv4 (len 4), Request who-has 10.0.1.2 tell 10.10.10.10, length 28
13:29:01.393739 08:00:27:3b:63:ae > ff:ff:ff:ff:ff:ff, ethertype ARP 
(0x0806), length 42: Ethernet (len 6),.
IPv4 (len 4), Request who-has 10.0.1.2 tell 10.0.1.1, length 28
13:29:01.393862 0a:00:27:00:00:00 > 08:00:27:3b:63:ae, ethertype ARP 
(0x0806), length 60: Ethernet (len 6),.
IPv4 (len 4), Reply 10.0.1.2 is-at 0a:00:27:00:00:00, length 46

Detailed information about this (and other, that triggers same case with 
ARP) network topology usage in real world
can be found at https://bugzilla.kernel.org/show_bug.cgi?id=49311

Sorry for early bug report.

-- 
SP5474-RIPE
Sergey Popovich
