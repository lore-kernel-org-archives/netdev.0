From: "dada1" <dada1@cosmosbay.com>
Subject: Performance problem with route cache ?
Date: Thu, 20 Nov 2003 11:55:05 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <02da01c3af54$c1f37f20$890010ac@edumazet>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all

I'm doing some oprofile on a bi athlon, linux-2.6.0-test8 kernel, (with a
copybreak intel e1000 patch, because the machine receives a lot of small (<
30 bytes) messages)

It seems the route cache may/should be tuned, but I dont know how.

The machine receives about 10000 packets/second, from a lot of different IP.

Cpu type: Athlon
Cpu speed was (MHz estimation) : 1991.43
Counter 0 counted CPU_CLK_UNHALTED events (Cycles outside of halt state)
with a unit mask of 0x00 (No unit mask) count
 50000
vma      samples  %           symbol name
a0251fd0 6477022  15.6789     rt_garbage_collect
a028b6a0 2692339  6.51731     ipt_do_table
a0254560 1779167  4.30681     ip_route_input
a0251c40 1544801  3.73948     rt_may_expire
a0273370 1119668  2.71037     tcp_v4_rcv
a01f4350 1084883  2.62616     e1000_clean_rx_irq
a013dd70 1048705  2.53859     free_block
a013e120 844766   2.04492     kfree
a0269cc0 600011   1.45244     tcp_rcv_established
a0111c20 540780   1.30906     mark_offset_tsc
a0235d40 536856   1.29956     skb_release_data
a023a9a0 521576   1.26257     net_rx_action
a0259dc0 515115   1.24693     ip_queue_xmit
a023f990 498217   1.20603     dst_alloc
a0260190 487681   1.18052     tcp_sendmsg
a0231fe0 477588   1.15609     sockfd_lookup
a0118c30 459348   1.11194     schedule
a0261bd0 454353   1.09985     tcp_recvmsg
a01070c0 442280   1.07062     default_idle

# grep ip_dst_cache /proc/slabinfo
ip_dst_cache      253051 324840    320   12    1 : tunables   54   27    8 :
slabdata  27070  27070      0

# cat /proc/net/sockstat
sockets: used 246459
TCP: inuse 245501 orphan 591 tw 5639 alloc 247035 mem 74061
UDP: inuse 6
RAW: inuse 0
FRAG: inuse 3 memory 1164

#grep "routing cache hash table " /var/log/syslog
kernel: IP: routing cache hash table of 32768 buckets, 256Kbytes

# cat /proc/meminfo
MemTotal:      3371408 kB
MemFree:        847716 kB
Buffers:         70352 kB
Cached:          91080 kB
SwapCached:          0 kB
Active:        1162512 kB
Inactive:        27360 kB
HighTotal:     1900544 kB
HighFree:       161920 kB
LowTotal:      1470864 kB
LowFree:        685796 kB
SwapTotal:      506008 kB
SwapFree:       506008 kB
Dirty:            2092 kB
Writeback:           0 kB
Mapped:        1038884 kB
Slab:           704636 kB
Committed_AS:  1549704 kB
PageTables:       1412 kB
VmallocTotal:    49144 kB
VmallocUsed:      2380 kB
VmallocChunk:    45896 kB
HugePages_Total:   150
HugePages_Free:     48
Hugepagesize:     4096 kB


Does anybody have a hint, what should I change to lower a bit the CPU used
in kernel land ?

Thanks

Eric Dumazet
