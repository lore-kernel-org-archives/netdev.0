From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Thu, 25 Jun 2009 17:48:59 +0200
Message-ID: <4A439C6B.9090502@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:51878 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752783AbZFYPs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2009 11:48:58 -0400
Received: from unknown (HELO [192.168.1.10]) (itcare_pstaszewski@[83.7.206.39])
          (envelope-sender <pstaszewski@itcare.pl>)
          by smtp.iq.pl with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 25 Jun 2009 15:48:59 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello ALL

Some time ago i report this:
http://bugzilla.kernel.org/show_bug.cgi?id=6648

and now with 2.6.29 / 2.6.29.1 / 2.6.29.3 and 2.6.30 it back
dmesg output:
oprofile: using NMI interrupt.
Fix inflate_threshold_root. Now=15 size=11 bits
Fix inflate_threshold_root. Now=15 size=11 bits
Fix inflate_threshold_root. Now=15 size=11 bits
Fix inflate_threshold_root. Now=15 size=11 bits
Fix inflate_threshold_root. Now=15 size=11 bits
Fix inflate_threshold_root. Now=15 size=11 bits
Fix inflate_threshold_root. Now=15 size=11 bits
Fix inflate_threshold_root. Now=15 size=11 bits
Fix inflate_threshold_root. Now=15 size=11 bits
Fix inflate_threshold_root. Now=15 size=11 bits
Fix inflate_threshold_root. Now=15 size=11 bits
Fix inflate_threshold_root. Now=15 size=11 bits
Fix inflate_threshold_root. Now=15 size=11 bits
Fix inflate_threshold_root. Now=15 size=11 bits
Fix inflate_threshold_root. Now=15 size=11 bits

cat /proc/net/fib_triestat
Basic info: size of leaf: 40 bytes, size of tnode: 56 bytes.
Main:
        Aver depth:     2.28
        Max depth:      6
        Leaves:         276539
        Prefixes:       289922
        Internal nodes: 66762
          1: 35046  2: 13824  3: 9508  4: 4897  5: 2331  6: 1149  7: 5  
9: 1  18: 1
        Pointers: 691228
Null ptrs: 347928
Total size: 35709  kB

Counters:
---------
gets = 26276593
backtracks = 547306
semantic match passed = 26188746
semantic match miss = 1117
null node hit= 27285055
skipped node resize = 0

Local:
        Aver depth:     3.33
        Max depth:      4
        Leaves:         9
        Prefixes:       10
        Internal nodes: 8
          1: 8
        Pointers: 16
Null ptrs: 0
Total size: 2  kB

Counters:
---------
gets = 26642350
backtracks = 1282818
semantic match passed = 18166
semantic match miss = 0
null node hit= 0
skipped node resize = 0



This machine is running bgpd with two bgp peers / full route table

 cat /proc/meminfo
MemTotal:       12279032 kB
MemFree:        11521920 kB
Buffers:           80288 kB
Cached:            34416 kB
SwapCached:            0 kB
Active:           286816 kB
Inactive:          82024 kB
Active(anon):     254296 kB
Inactive(anon):        0 kB
Active(file):      32520 kB
Inactive(file):    82024 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:        987988 kB
SwapFree:         987988 kB
Dirty:              1140 kB
Writeback:             0 kB
AnonPages:        254164 kB
Mapped:             5440 kB
Slab:             365084 kB
SReclaimable:      28784 kB
SUnreclaim:       336300 kB
PageTables:         2104 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     7127504 kB
Committed_AS:     267704 kB
VmallocTotal:   34359738367 kB
VmallocUsed:       11824 kB
VmallocChunk:   34359707815 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:        3392 kB
DirectMap2M:    12578816 kB


Interfaces mtu is1500

