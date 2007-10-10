From: "Denys" <denys@visp.net.lb>
Subject: Possible 2.6.22 -> 2.6.23 HTB regression?
Date: Wed, 10 Oct 2007 15:05:47 +0300
Message-ID: <20071010114605.M50671@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:46863 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752924AbXJJMat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 08:30:49 -0400
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id 2B783BE0F4
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2007 15:05:47 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi 2 all again

I have shaper, running very simple HTB tree (about 10 classes).

Traffic is coming via eth0, and going over eth0.1000, shaper installed on 
eth0.1000 (802.1Q vlan), total rate is 85Mbit/s.

On kernel 2.6.22 with bnx2 eth0 everything was working fine.

I have another server with similar task, with e1000, and was shaping rate 
lower than expected on 2.6.22. On full load it was 65-66Mbit/s instead 88Mbit/
s. So i postpone troubleshooting, and moved it as backup server.

When i upgrade server with bnx2 to 2.6.23 i got the same behaviour on bnx2 
too.

Even with extended burst/cburst it is around 82.5Mbit/s instead 85Mbit/s. 
(calculation with 5 second delay)
82319/82354 KBit/S (52684221/52706721) (0/0)
82375/82368 KBit/S (52720558/52716058) (52684221/52706721)
82500/82500 KBit/S (52800425/52800425) (105404779/105422779)
82406/82406 KBit/S (52740119/52740119) (158205204/158223204)
82615/82631 KBit/S (52873964/52884464) (210945323/210963323)
82459/82464 KBit/S (52774379/52777379) (263819287/263847787)


Here is tc -s -d class show dev eth0.2022 when i run without custom burst/
cburst (after 60 seconds)

class htb 1:100 root rate 85000Kbit ceil 85000Kbit burst 1583b/8 mpu 0b 
overhead 0b cburst 1583b/8 mpu 0b overhead 0b level 7
 Sent 511732440 bytes 348298 pkt (dropped 0, overlimits 0 requeues 0)
 rate 67637Kbit 5774pps backlog 0b 0p requeues 0
 lended: 4029 borrowed: 0 giants: 0
 tokens: -764 ctokens: -764

class htb 1:200 parent 1:100 leaf 200: prio 0 quantum 2000 rate 5000Kbit ceil 
85000Kbit burst 1600b/8 mpu 0b overhead 0b cburst 1583b/8 mpu 0b overhead 0b 
level 0
 Sent 1785787 bytes 8180 pkt (dropped 0, overlimits 0 requeues 0)
 rate 312608bit 162pps backlog 0b 0p requeues 0
 lended: 8090 borrowed: 90 giants: 0
 tokens: 2426 ctokens: 143

class htb 1:923 parent 1:920 leaf 923: prio 0 quantum 2000 rate 5000Kbit ceil 
85000Kbit burst 1600b/8 mpu 0b overhead 0b cburst 1583b/8 mpu 0b overhead 0b 
level 0
 Sent 16491797 bytes 10896 pkt (dropped 0, overlimits 0 requeues 0)
 rate 2171Kbit 179pps backlog 0b 0p requeues 0
 lended: 10673 borrowed: 223 giants: 0
 tokens: 138 ctokens: 8

class htb 1:910 parent 1:900 leaf 910: prio 0 quantum 2000 rate 50000Kbit 
ceil 85000Kbit burst 1600b/8 mpu 0b overhead 0b cburst 1583b/8 mpu 0b 
overhead 0b level 0
 Sent 276577122 bytes 185876 pkt (dropped 7427, overlimits 0 requeues 0)
 rate 36497Kbit 3065pps backlog 0b 444p requeues 0
 lended: 182521 borrowed: 2911 giants: 0
 tokens: -455 ctokens: -117

class htb 1:922 parent 1:920 leaf 922: prio 5 quantum 2000 rate 5000Kbit ceil 
85000Kbit burst 1600b/8 mpu 0b overhead 0b cburst 1583b/8 mpu 0b overhead 0b 
level 0
 Sent 56949991 bytes 37706 pkt (dropped 34663, overlimits 0 requeues 0)
 rate 7298Kbit 604pps backlog 0b 823p requeues 0
 lended: 24844 borrowed: 12039 giants: 0
 tokens: -4641 ctokens: -110

class htb 1:900 parent 1:100 rate 80000Kbit ceil 85000Kbit burst 1590b/8 mpu 
0b overhead 0b cburst 1583b/8 mpu 0b overhead 0b level 6
 Sent 509946653 bytes 340118 pkt (dropped 0, overlimits 0 requeues 0)
 rate 67324Kbit 5612pps backlog 0b 0p requeues 0
 lended: 10152 borrowed: 3939 giants: 0
 tokens: -850 ctokens: -764

class htb 1:921 parent 1:920 leaf 921: prio 5 quantum 2000 rate 20000Kbit 
ceil 85000Kbit burst 1600b/8 mpu 0b overhead 0b cburst 1583b/8 mpu 0b 
overhead 0b level 0
 Sent 162349726 bytes 107246 pkt (dropped 51305, overlimits 0 requeues 0)
 rate 21252Kbit 1755pps backlog 0b 339p requeues 0
 lended: 94785 borrowed: 12122 giants: 0
 tokens: -1113 ctokens: -239

class htb 1:920 parent 1:900 rate 30000Kbit ceil 85000Kbit burst 1593b/8 mpu 
0b overhead 0b cburst 1583b/8 mpu 0b overhead 0b level 5
 Sent 234033699 bytes 154686 pkt (dropped 0, overlimits 0 requeues 0)
 rate 30719Kbit 2538pps backlog 0b 0p requeues 0
 lended: 13204 borrowed: 11180 giants: 0
 tokens: -1780 ctokens: -505



Here is tc -s -d class show dev eth0.2022 when i run WITH custom burst/cburst 
(after 60 seconds)

class htb 1:100 root rate 85000Kbit ceil 85000Kbit burst 16Kb/8 mpu 0b 
overhead 0b cburst 8Kb/8 mpu 0b overhead 0b level 7
 Sent 637707898 bytes 430930 pkt (dropped 0, overlimits 0 requeues 0)
 rate 83982Kbit 7082pps backlog 0b 0p requeues 0
 lended: 22809 borrowed: 0 giants: 0
 tokens: -2453 ctokens: -3206

class htb 1:200 parent 1:100 leaf 200: prio 0 quantum 2000 rate 5000Kbit ceil 
85000Kbit burst 16Kb/8 mpu 0b overhead 0b cburst 8Kb/8 mpu 0b overhead 0b 
level 0
 Sent 1266780 bytes 7041 pkt (dropped 0, overlimits 0 requeues 0)
 rate 128920bit 102pps backlog 0b 0p requeues 0
 lended: 6983 borrowed: 58 giants: 0
 tokens: 23250 ctokens: 615

class htb 1:923 parent 1:920 leaf 923: prio 0 quantum 2000 rate 5000Kbit ceil 
85000Kbit burst 16Kb/8 mpu 0b overhead 0b cburst 8Kb/8 mpu 0b overhead 0b 
level 0
 Sent 16484432 bytes 10888 pkt (dropped 0, overlimits 0 requeues 0)
 rate 2172Kbit 179pps backlog 0b 0p requeues 0
 lended: 10888 borrowed: 0 giants: 0
 tokens: 18537 ctokens: 362

class htb 1:910 parent 1:900 leaf 910: prio 0 quantum 2000 rate 50000Kbit 
ceil 85000Kbit burst 16Kb/8 mpu 0b overhead 0b cburst 8Kb/8 mpu 0b overhead 
0b level 0
 Sent 278162766 bytes 187188 pkt (dropped 0, overlimits 0 requeues 0)
 rate 34963Kbit 2943pps backlog 0b 19p requeues 0
 lended: 182346 borrowed: 4823 giants: 0
 tokens: -2472 ctokens: -755

class htb 1:922 parent 1:920 leaf 922: prio 5 quantum 2000 rate 5000Kbit ceil 
85000Kbit burst 16Kb/8 mpu 0b overhead 0b cburst 8Kb/8 mpu 0b overhead 0b 
level 0
 Sent 119217036 bytes 78793 pkt (dropped 23901, overlimits 0 requeues 0)
 rate 16355Kbit 1351pps backlog 0b 653p requeues 0
 lended: 24715 borrowed: 53425 giants: 0
 tokens: -25785 ctokens: -691

class htb 1:900 parent 1:100 rate 80000Kbit ceil 85000Kbit burst 16Kb/8 mpu 
0b overhead 0b cburst 8Kb/8 mpu 0b overhead 0b level 6
 Sent 636441118 bytes 423889 pkt (dropped 0, overlimits 0 requeues 0)
 rate 83853Kbit 6981pps backlog 0b 0p requeues 0
 lended: 69858 borrowed: 22751 giants: 0
 tokens: -3801 ctokens: -3063

class htb 1:921 parent 1:920 leaf 921: prio 5 quantum 2000 rate 20000Kbit 
ceil 85000Kbit burst 16Kb/8 mpu 0b overhead 0b cburst 8Kb/8 mpu 0b overhead 
0b level 0
 Sent 224022740 bytes 147977 pkt (dropped 36921, overlimits 0 requeues 0)
 rate 30486Kbit 2517pps backlog 0b 285p requeues 0
 lended: 98381 borrowed: 49311 giants: 0
 tokens: -6581 ctokens: -851

class htb 1:920 parent 1:900 rate 30000Kbit ceil 85000Kbit burst 16Kb/8 mpu 
0b overhead 0b cburst 8Kb/8 mpu 0b overhead 0b level 5
 Sent 358305020 bytes 236720 pkt (dropped 0, overlimits 0 requeues 0)
 rate 48861Kbit 4035pps backlog 0b 0p requeues 0
 lended: 14950 borrowed: 87786 giants: 0
 tokens: -7376 ctokens: -851


Bandwidth stats when i run with custom cburst/burst
81932/81932 KBit/S (52436973/52436973) (7697899990/7698153316)
82465/82463 KBit/S (52778238/52776738) (7750336963/7750590289)
82289/82291 KBit/S (52665172/52666672) (7803115201/7803367027)
Now i run without them
65812/65812 KBit/S (42119718/42119718) (7855780373/7856033699)
65300/65300 KBit/S (41792304/41792304) (7897900091/7898153417)
67133/67133 KBit/S (42965445/42965445) (7939692395/7939945721)

Right now shaper looks like this (burst and cburst added recently,it helps a 
bit to increase rate):
#!/bin/sh
DEV=eth0.2022

ROOTRATE=85000Kbit

tc qdisc del dev ${DEV} root

tc qdisc add dev ${DEV} root handle 1: htb default 2000

tc class add dev ${DEV} parent 1: classid 1:100 htb rate ${ROOTRATE}  quantum 
2000 burst 16k cburst 8k



tc class add dev ${DEV} parent 1:100 classid 1:200 htb rate 5000Kbit ceil 
${ROOTRATE}  quantum 2000 burst 16k cburst 8k
tc qdisc add dev ${DEV} parent 1:200 handle 200: bfifo limit 5120000

tc filter add dev ${DEV} parent 1:0 prio 1100 protocol ip u32 match ip dst 
0.0.0.0/0 classid 1:200



tc class add dev ${DEV} parent 1:100 classid 1:900 htb rate 80000Kbit ceil 
${ROOTRATE}  quantum 2000 burst 16k cburst 8k

#SUPERCAFE


#Browsing
tc class add dev ${DEV} parent 1:900 classid 1:910 htb rate 50000Kbit ceil 
${ROOTRATE}  quantum 2000 burst 16k cburst 8k
tc qdisc add dev ${DEV} parent 1:910 handle 910: bfifo limit 2120000
tc filter add dev ${DEV} parent 1:0 prio 100 protocol ip u32 match ip src 
217.151.224.29/32 match ip protocol 17 0xff match ip sport 21004 0xffff 
classid 1:910



#Downloads
tc class add dev ${DEV} parent 1:900 classid 1:920 htb rate 30000Kbit ceil 
${ROOTRATE}  quantum 2000 burst 16k cburst 8k



tc class add dev ${DEV} parent 1:920 classid 1:921 htb rate 20000Kbit ceil 
${ROOTRATE}  quantum 2000 burst 16k cburst 8k prio 5
tc qdisc add dev ${DEV} parent 1:921 handle 921: bfifo limit 520000
tc filter add dev ${DEV} parent 1:0 prio 95 protocol ip u32 match ip src 
217.151.224.29/32 match ip protocol 17 0xff match ip sport 21005 0xffff match 
ip dst 213.187.247.1/32 classid 1:921
tc filter add dev ${DEV} parent 1:0 prio 95 protocol ip u32 match ip src 
217.151.224.29/32 match ip protocol 17 0xff match ip sport 21005 0xffff match 
ip dst 213.187.247.2/32 classid 1:921
tc filter add dev ${DEV} parent 1:0 prio 95 protocol ip u32 match ip src 
217.151.224.29/32 match ip protocol 17 0xff match ip sport 21005 0xffff match 
ip dst 213.187.247.3/32 classid 1:921


tc class add dev ${DEV} parent 1:920 classid 1:922 htb rate 5000Kbit ceil 
${ROOTRATE}  quantum 2000 burst 16k cburst 8k prio 5
tc qdisc add dev ${DEV} parent 1:922 handle 922: bfifo limit 1250000
tc filter add dev ${DEV} parent 1:0 prio 100 protocol ip u32 match ip src 
217.151.224.29/32 match ip protocol 17 0xff match ip sport 21005 0xffff 
classid 1:922

tc class add dev ${DEV} parent 1:920 classid 1:923 htb rate 5000Kbit ceil 
${ROOTRATE}  quantum 2000 burst 16k cburst 8k
tc qdisc add dev ${DEV} parent 1:923 handle 923: bfifo limit 500000
tc filter add dev ${DEV} parent 1:0 prio 20 protocol ip u32 match ip dst 
213.187.247.11/32 classid 1:923



--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

