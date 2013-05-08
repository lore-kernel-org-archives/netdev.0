From: Cong Wang <amwang@redhat.com>
Subject: Regression: too many packets with incorrect checksum
Date: Wed, 08 May 2013 19:51:28 +0800
Message-ID: <1368013888.3115.9.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32523 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755015Ab3EHLve (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 May 2013 07:51:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, all

The latest -net tree has some regression, I saw too many packets with
incorrect checksum from tcpdump inside a KVM guest, see the bottom.
(firewall is turned off on both sides.)

It seems this is not related with drivers, I tried virtio and e1000,
both have the same problem. And UDP has the problem too. But turning off
tx-checksum by `ethtool -K eth0 tx off` makes the problem disappear
(just turning off TSO or GSO doesn't make any difference).

I can provide other information if you need.

# tcpdump -i eth0 -vvv src host 192.168.122.45
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size
65535 bytes
19:24:14.545355 IP (tos 0x0, ttl 64, id 23831, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x9924), seq 3699921116, ack 4088995329, win 613, options [nop,nop,TS
val 4294905432 ecr 4294882117], length 0
19:24:14.547680 IP (tos 0x0, ttl 64, id 23832, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x998b), seq 0, ack 65161, win 872, options [nop,nop,TS val
4294905432 ecr 4294882130], length 0
19:24:14.552225 IP (tos 0x0, ttl 64, id 23833, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0xe6c0), seq 0, ack 176657, win 677, options [nop,nop,TS val
4294905434 ecr 4294882132], length 0
19:24:14.553894 IP (tos 0x0, ttl 64, id 23834, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x9efd), seq 0, ack 260641, win 594, options [nop,nop,TS val
4294905434 ecr 4294882137], length 0
19:24:14.561437 IP (tos 0x0, ttl 64, id 23835, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x9f6d), seq 0, ack 325801, win 853, options [nop,nop,TS val
4294905436 ecr 4294882139], length 0
19:24:14.563031 IP (tos 0x0, ttl 64, id 23836, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0xf7df), seq 0, ack 434401, win 674, options [nop,nop,TS val
4294905436 ecr 4294882146], length 0
19:24:14.566173 IP (tos 0x0, ttl 64, id 23837, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0xf4d5), seq 0, ack 434401, win 1451, options [nop,nop,TS val
4294905437 ecr 4294882146], length 0
19:24:14.567341 IP (tos 0x0, ttl 64, id 23838, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0xa462), seq 0, ack 586441, win 1074, options [nop,nop,TS val
4294905437 ecr 4294882148], length 0
19:24:14.569090 IP (tos 0x0, ttl 64, id 23839, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0xa84e), seq 0, ack 716761, win 815, options [nop,nop,TS val
4294905438 ecr 4294882152], length 0
19:24:14.592676 IP (tos 0x0, ttl 64, id 23840, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x1092), seq 0, ack 821017, win 930, options [nop,nop,TS val
4294905444 ecr 4294882154], length 0
19:24:14.603615 IP (tos 0x0, ttl 64, id 23841, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x0c84), seq 0, ack 821017, win 1966, options [nop,nop,TS val
4294905446 ecr 4294882154], length 0
19:24:14.606856 IP (tos 0x0, ttl 64, id 23842, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0xa872), seq 0, ack 912241, win 1870, options [nop,nop,TS val
4294905447 ecr 4294882177], length 0
19:24:15.441196 IP (tos 0x0, ttl 64, id 23977, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x17ff), seq 0, ack 17462881, win 2167, options [nop,nop,TS val
4294905656 ecr 4294882830], length 0
19:24:15.453833 IP (tos 0x0, ttl 64, id 23978, offset 0, flags [DF],
proto TCP (6), length 64)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75b2 (incorrect
-> 0xcb7e), seq 0, ack 17658361, win 1390, options [nop,nop,TS val
4294905659 ecr 4294882835,nop,nop,sack 1 {17332561:17334009}], length 0
19:24:15.456982 IP (tos 0x0, ttl 64, id 23979, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x220a), seq 0, ack 17788681, win 1259, options [nop,nop,TS val
4294905660 ecr 4294883038], length 0
19:24:15.462840 IP (tos 0x0, ttl 64, id 23980, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x21e3), seq 0, ack 17853841, win 1668, options [nop,nop,TS val
4294905661 ecr 4294883042], length 0
19:24:15.466116 IP (tos 0x0, ttl 64, id 23981, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x2359), seq 0, ack 17919001, win 1668, options [nop,nop,TS val
4294905662 ecr 4294883042], length 0
19:24:15.566660 IP (tos 0x0, ttl 64, id 23982, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x282e), seq 0, ack 18049321, win 1150, options [nop,nop,TS val
4294905687 ecr 4294883048], length 0
19:24:15.585390 IP (tos 0x0, ttl 64, id 23983, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x299d), seq 0, ack 18114481, win 1150, options [nop,nop,TS val
4294905692 ecr 4294883051], length 0
19:24:15.591274 IP (tos 0x0, ttl 64, id 23984, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x2364), seq 0, ack 18114481, win 2742, options [nop,nop,TS val
4294905693 ecr 4294883051], length 0
19:24:15.649714 IP (tos 0x0, ttl 64, id 23985, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x27d7), seq 0, ack 18244801, win 2224, options [nop,nop,TS val
4294905708 ecr 4294883165], length 0
19:24:15.729772 IP (tos 0x0, ttl 64, id 23986, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x31a0), seq 0, ack 18505441, win 1188, options [nop,nop,TS val
4294905728 ecr 4294883176], length 0
19:24:15.733080 IP (tos 0x0, ttl 64, id 23987, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x328b), seq 0, ack 18570601, win 1188, options [nop,nop,TS val
4294905729 ecr 4294883315], length 0
19:24:15.772470 IP (tos 0x0, ttl 64, id 23988, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x3775), seq 0, ack 18700921, win 670, options [nop,nop,TS val
4294905739 ecr 4294883315], length 0
19:24:15.803842 IP (tos 0x0, ttl 64, id 23989, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x37b8), seq 0, ack 18766081, win 929, options [nop,nop,TS val
4294905745 ecr 4294883358], length 0
19:24:15.812830 IP (tos 0x0, ttl 64, id 23990, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x390c), seq 0, ack 18831241, win 929, options [nop,nop,TS val
4294905749 ecr 4294883389], length 0
19:24:15.817814 IP (tos 0x0, ttl 64, id 23991, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x6a1c), seq 0, ack 18949977, win 702, options [nop,nop,TS val
4294905750 ecr 4294883389], length 0
19:24:15.843020 IP (tos 0x0, ttl 64, id 23992, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x3d5c), seq 0, ack 19026721, win 929, options [nop,nop,TS val
4294905756 ecr 4294883403], length 0
19:24:15.858726 IP (tos 0x0, ttl 64, id 23993, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x6e49), seq 0, ack 19145457, win 702, options [nop,nop,TS val
4294905760 ecr 4294883435], length 0
19:24:15.869397 IP (tos 0x0, ttl 64, id 23994, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x42a0), seq 0, ack 19222201, win 651, options [nop,nop,TS val
4294905763 ecr 4294883451], length 0
19:24:15.885676 IP (tos 0x0, ttl 64, id 23995, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x430d), seq 0, ack 19287361, win 910, options [nop,nop,TS val
4294905767 ecr 4294883454], length 0
19:24:15.894209 IP (tos 0x0, ttl 64, id 23996, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x7f4e), seq 0, ack 19403201, win 699, options [nop,nop,TS val
4294905767 ecr 4294883470], length 0
19:24:15.913824 IP (tos 0x0, ttl 64, id 23997, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x7c3f), seq 0, ack 19403201, win 1476, options [nop,nop,TS val
4294905773 ecr 4294883470], length 0
19:24:15.929151 IP (tos 0x0, ttl 64, id 23998, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x4551), seq 0, ack 19482841, win 1409, options [nop,nop,TS val
4294905778 ecr 4294883489], length 0
19:24:15.935134 IP (tos 0x0, ttl 64, id 23999, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x4935), seq 0, ack 19613161, win 1150, options [nop,nop,TS val
4294905779 ecr 4294883501], length 0
19:24:15.947475 IP (tos 0x0, ttl 64, id 24000, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x4993), seq 0, ack 19678321, win 1409, options [nop,nop,TS val
4294905782 ecr 4294883520], length 0
19:24:15.955810 IP (tos 0x0, ttl 64, id 24001, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x4b08), seq 0, ack 19743481, win 1409, options [nop,nop,TS val
4294905784 ecr 4294883520], length 0
19:24:15.972438 IP (tos 0x0, ttl 64, id 24002, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x4c6d), seq 0, ack 19808641, win 1409, options [nop,nop,TS val
4294905789 ecr 4294883533], length 0
19:24:15.986133 IP (tos 0x0, ttl 64, id 24003, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x4cd6), seq 0, ack 19873801, win 1668, options [nop,nop,TS val
4294905792 ecr 4294883541], length 0
19:24:15.993788 IP (tos 0x0, ttl 64, id 24004, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x532f), seq 0, ack 20069281, win 1150, options [nop,nop,TS val
4294905794 ecr 4294883557], length 0
19:24:16.014866 IP (tos 0x0, ttl 64, id 24005, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x5478), seq 0, ack 20134441, win 1169, options [nop,nop,TS val
4294905799 ecr 4294883579], length 0
19:24:16.025049 IP (tos 0x0, ttl 64, id 24006, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x54d6), seq 0, ack 20199601, win 1447, options [nop,nop,TS val
4294905802 ecr 4294883579], length 0
19:24:16.041887 IP (tos 0x0, ttl 64, id 24007, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x589b), seq 0, ack 20329921, win 1207, options [nop,nop,TS val
4294905806 ecr 4294883600], length 0
19:24:16.046153 IP (tos 0x0, ttl 64, id 24008, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x5c71), seq 0, ack 20460241, win 948, options [nop,nop,TS val
4294905806 ecr 4294883627], length 0
19:24:16.065740 IP (tos 0x0, ttl 64, id 24009, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x86cd), seq 0, ack 20580425, win 980, options [nop,nop,TS val
4294905812 ecr 4294883631], length 0
19:24:16.073606 IP (tos 0x0, ttl 64, id 24010, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x5e4f), seq 0, ack 20590561, win 1188, options [nop,nop,TS val
4294905814 ecr 4294883651], length 0
19:24:16.091362 IP (tos 0x0, ttl 64, id 24011, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0xa044), seq 0, ack 20704953, win 977, options [nop,nop,TS val
4294905818 ecr 4294883651], length 0
19:24:16.102390 IP (tos 0x0, ttl 64, id 24012, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0xb9bb), seq 0, ack 20829481, win 990, options [nop,nop,TS val
4294905821 ecr 4294883658], length 0
19:24:16.114682 IP (tos 0x0, ttl 64, id 24013, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x6410), seq 0, ack 20851201, win 1169, options [nop,nop,TS val
4294905824 ecr 4294883687], length 0
19:24:16.148525 IP (tos 0x0, ttl 64, id 24014, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x657e), seq 0, ack 20916361, win 1169, options [nop,nop,TS val
4294905833 ecr 4294883687], length 0
19:24:16.158364 IP (tos 0x0, ttl 64, id 24015, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x6a64), seq 0, ack 21046681, win 651, options [nop,nop,TS val
4294905835 ecr 4294883699], length 0
19:24:16.167386 IP (tos 0x0, ttl 64, id 24016, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x6aa9), seq 0, ack 21111841, win 910, options [nop,nop,TS val
4294905836 ecr 4294883745], length 0
19:24:16.175154 IP (tos 0x0, ttl 64, id 24017, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x6c16), seq 0, ack 21177001, win 910, options [nop,nop,TS val
4294905839 ecr 4294883752], length 0
19:24:16.195416 IP (tos 0x0, ttl 64, id 24018, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0xa875), seq 0, ack 21292841, win 680, options [nop,nop,TS val
4294905844 ecr 4294883752], length 0
19:24:16.221799 IP (tos 0x0, ttl 64, id 24019, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x706b), seq 0, ack 21372481, win 872, options [nop,nop,TS val
4294905851 ecr 4294883794], length 0
19:24:16.237832 IP (tos 0x0, ttl 64, id 24020, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0xbd93), seq 0, ack 21483977, win 677, options [nop,nop,TS val
4294905855 ecr 4294883807], length 0
19:24:16.248822 IP (tos 0x0, ttl 64, id 24021, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x75c2), seq 0, ack 21567961, win 594, options [nop,nop,TS val
4294905858 ecr 4294883823], length 0
19:24:16.257904 IP (tos 0x0, ttl 64, id 24022, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x762b), seq 0, ack 21633121, win 853, options [nop,nop,TS val
4294905858 ecr 4294883834], length 0
19:24:16.266744 IP (tos 0x0, ttl 64, id 24023, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0x778e), seq 0, ack 21698281, win 853, options [nop,nop,TS val
4294905862 ecr 4294883850], length 0
19:24:16.280420 IP (tos 0x0, ttl 64, id 24024, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0xcd89), seq 0, ack 21741721, win 933, options [nop,nop,TS val
4294905866 ecr 4294883850], length 0
19:24:16.290172 IP (tos 0x0, ttl 64, id 24025, offset 0, flags [DF],
proto TCP (6), length 52)
    f17.49579 > 192.168.122.1.41803: Flags [.], cksum 0x75a6 (incorrect
-> 0xce0d), seq 0, ack 21806881, win 1173, options [nop,nop,TS val
4294905868 ecr 4294883851], length 0

61 packets captured
81 packets received by filter
180 packets dropped by kernel
