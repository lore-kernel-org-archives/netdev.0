From: =?UTF-8?Q?Nie=C5=9Bcierowicz_Adam?= <adam.niescierowicz@justnet.pl>
Subject: tc filter u32 match
Date: Tue, 22 May 2012 15:42:58 +0200
Message-ID: <32a6182e71dd565206cf39d4cad3f984@justnet.pl>
Reply-To: <adam.niescierowicz@justnet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-91.230.163.37.ltv.pl ([91.230.163.37]:46463 "EHLO
	mail.justnet.pl" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1757122Ab2EVO23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 10:28:29 -0400
Received: from [91.230.163.37] (helo=mail.justnet.pl)
	by service with esmtpa (Exim 4.72)
	(envelope-from <adam.niescierowicz@justnet.pl>)
	id 1SWpMY-0005fq-Sp
	for netdev@vger.kernel.org; Tue, 22 May 2012 15:42:58 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm in the process of building a new shaper, when adding support for 
802.1q
vlan noticed that u32 can catch network traffic without giving 4 bytes
offset. How is this possible?

My environment:

eth2 - network card
eth2.200 - vlan

/sbin/tc filter add dev eth2 parent 1:0 prio 5 handle 35: protocol ip 
u32 divisor 256
/sbin/tc filter add dev eth2 protocol ip parent 1:0 prio 5 u32 ht 800:: 
match ip dst 31.41.208.32/27 hashkey mask 0x000000ff at 16 link 35:
/sbin/tc filter add dev eth2 protocol ip parent 1: prio 1 u32 ht 35:24: 
match ip dst 31.41.208.36 flowid 1:2e5

Here you can see the hits in the rule
filter parent 1: protocol ip pref 5 u32 fh 35:24:800 order 2048 key ht 
35 bkt 24 flowid 1:2e5  (rule hit 44037 success 44037)
   match 1f29d024/ffffffff at 16 (success 44037 )


I found a similar question here 
http://serverfault.com/questions/370795/tc-u32-how-to-match-l2-protocols-in-recent-kernels

Thanks
