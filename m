From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: purpose of the skb head pool
Date: Tue, 29 Apr 2003 15:05:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16046.30879.738356.495523@robur.slu.se>
References: <20030429135506.A22411@lst.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VOhjG1twcL"
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20030429135506.A22411@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--VOhjG1twcL
Content-Type: text/plain; charset=us-ascii
Content-Description: message body text
Content-Transfer-Encoding: 7bit


 Hello!

Christoph Hellwig writes:
 > net/core/skbuf.c has a small per-cpu pool to keep some hot skbufs around
 > instead of returning them to the system allocator.  But if you loook
 > at the slab allocator we'll have exactly that same code duplicated in
 > there (see functions ac_data, __cache_alloc and kmem_cache_alloc in
 > slab.c).  So is there some other reason why this pool is needed?

 Well just happened test without it yesterday... 

 Manfred is working on some improvements of the slab (magazine layer) so I  
 tested this. It seems to do improve performance. I also removed the 
 skb_head_pool for a test run.

 2.6.66 IP. Forwarding of two input simplex flows. eth0->eth1, eth2->eth3 
 Fixed affinity CPU0: eth0, eth3. CPU1: eth1, eth2. Which common for routing
 and should be "worst case" for other use. The test should give a very high 
 load on the packet memory system. As seen at least we don't see any
 improvement from skb_head_pool code. 


 Vanilla 2.5.66              381 kpps
 Magazine                    431 kpps
 Magazine + no skb_head_pool 435 kpps


 Cheers.
						--ro


 
--VOhjG1twcL
Content-Type: application/octet-stream
Content-Disposition: attachment;
	filename="rem_skb_head_pool.pat"
Content-Transfer-Encoding: base64

LS0tIGxpbnV4L25ldC9jb3JlL3NrYnVmZi5jLjAzMDQyOAkyMDAzLTA0LTAxIDEzOjI0OjE0
LjAwMDAwMDAwMCArMDIwMAorKysgbGludXgvbmV0L2NvcmUvc2tidWZmLmMJMjAwMy0wNC0y
OCAxNjo1Mzo1NC4wMDAwMDAwMDAgKzAyMDAKQEAgLTIwLDcgKzIwLDcgQEAKICAqCQlSYXkg
VmFuVGFzc2xlCToJRml4ZWQgLS1za2ItPmxvY2sgaW4gZnJlZQogICoJCUFsYW4gQ294CToJ
c2tiX2NvcHkgY29weSBhcnAgZmllbGQKICAqCQlBbmRpIEtsZWVuCToJc2xhYmlmaWVkIGl0
LgorICoJCVJvYmVydCBPbHNzb24JOglSZW1vdmVkIHNrYl9oZWFkX3Bvb2wKICAqCiAgKglO
T1RFOgogICoJCVRoZSBfX3NrYl8gcm91dGluZXMgc2hvdWxkIGJlIGNhbGxlZCB3aXRoIGlu
dGVycnVwdHMKQEAgLTY0LDE1ICs2NCw4IEBACiAjaW5jbHVkZSA8YXNtL3VhY2Nlc3MuaD4K
ICNpbmNsdWRlIDxhc20vc3lzdGVtLmg+CiAKLWludCBzeXNjdGxfaG90X2xpc3RfbGVuID0g
MTI4OwotCiBzdGF0aWMga21lbV9jYWNoZV90ICpza2J1ZmZfaGVhZF9jYWNoZTsKIAotc3Rh
dGljIHVuaW9uIHsKLQlzdHJ1Y3Qgc2tfYnVmZl9oZWFkCWxpc3Q7Ci0JY2hhcgkJCXBhZFtT
TVBfQ0FDSEVfQllURVNdOwotfSBza2JfaGVhZF9wb29sW05SX0NQVVNdOwotCiAvKgogICoJ
S2VlcCBvdXQtb2YtbGluZSB0byBwcmV2ZW50IGtlcm5lbCBibG9hdC4KICAqCV9fYnVpbHRp
bl9yZXR1cm5fYWRkcmVzcyBpcyBub3QgdXNlZCBiZWNhdXNlIGl0IGlzIG5vdCBhbHdheXMK
QEAgLTExMCw0NCArMTAzLDYgQEAKIAlCVUcoKTsKIH0KIAotc3RhdGljIF9faW5saW5lX18g
c3RydWN0IHNrX2J1ZmYgKnNrYl9oZWFkX2Zyb21fcG9vbCh2b2lkKQotewotCXN0cnVjdCBz
a19idWZmX2hlYWQgKmxpc3Q7Ci0Jc3RydWN0IHNrX2J1ZmYgKnNrYiA9IE5VTEw7Ci0JdW5z
aWduZWQgbG9uZyBmbGFnczsKLQotCWxvY2FsX2lycV9zYXZlKGZsYWdzKTsKLQotCWxpc3Qg
PSAmc2tiX2hlYWRfcG9vbFtzbXBfcHJvY2Vzc29yX2lkKCldLmxpc3Q7Ci0KLQlpZiAoc2ti
X3F1ZXVlX2xlbihsaXN0KSkKLQkJc2tiID0gX19za2JfZGVxdWV1ZShsaXN0KTsKLQotCWxv
Y2FsX2lycV9yZXN0b3JlKGZsYWdzKTsKLQlyZXR1cm4gc2tiOwotfQotCi1zdGF0aWMgX19p
bmxpbmVfXyB2b2lkIHNrYl9oZWFkX3RvX3Bvb2woc3RydWN0IHNrX2J1ZmYgKnNrYikKLXsK
LQlzdHJ1Y3Qgc2tfYnVmZl9oZWFkICpsaXN0OwotCXVuc2lnbmVkIGxvbmcgZmxhZ3M7Ci0K
LQlsb2NhbF9pcnFfc2F2ZShmbGFncyk7Ci0KLQlsaXN0ID0gJnNrYl9oZWFkX3Bvb2xbc21w
X3Byb2Nlc3Nvcl9pZCgpXS5saXN0OwotCi0JaWYgKHNrYl9xdWV1ZV9sZW4obGlzdCkgPCBz
eXNjdGxfaG90X2xpc3RfbGVuKSB7Ci0JCV9fc2tiX3F1ZXVlX2hlYWQobGlzdCwgc2tiKTsK
LQkJbG9jYWxfaXJxX3Jlc3RvcmUoZmxhZ3MpOwotCi0JCXJldHVybjsKLQl9Ci0KLQlsb2Nh
bF9pcnFfcmVzdG9yZShmbGFncyk7Ci0Ja21lbV9jYWNoZV9mcmVlKHNrYnVmZl9oZWFkX2Nh
Y2hlLCBza2IpOwotfQotCi0KIC8qIAlBbGxvY2F0ZSBhIG5ldyBza2J1ZmYuIFdlIGRvIHRo
aXMgb3Vyc2VsdmVzIHNvIHdlIGNhbiBmaWxsIGluIGEgZmV3CiAgKgkncHJpdmF0ZScgZmll
bGRzIGFuZCBhbHNvIGRvIG1lbW9yeSBzdGF0aXN0aWNzIHRvIGZpbmQgYWxsIHRoZQogICoJ
W0JFRVBdIGxlYWtzLgpAQCAtMTgyLDEzICsxMzcsMTAgQEAKIAl9CiAKIAkvKiBHZXQgdGhl
IEhFQUQgKi8KLQlza2IgPSBza2JfaGVhZF9mcm9tX3Bvb2woKTsKLQlpZiAoIXNrYikgewot
CQlza2IgPSBrbWVtX2NhY2hlX2FsbG9jKHNrYnVmZl9oZWFkX2NhY2hlLAorCXNrYiA9IGtt
ZW1fY2FjaGVfYWxsb2Moc2tidWZmX2hlYWRfY2FjaGUsCiAJCQkJICAgICAgIGdmcF9tYXNr
ICYgfl9fR0ZQX0RNQSk7CiAJCWlmICghc2tiKQogCQkJZ290byBvdXQ7Ci0JfQogCiAJLyog
R2V0IHRoZSBEQVRBLiBTaXplIG11c3QgbWF0Y2ggc2tiX2FkZF9tdHUoKS4gKi8KIAlzaXpl
ID0gU0tCX0RBVEFfQUxJR04oc2l6ZSk7CkBAIC0yMDcsNyArMTU5LDcgQEAKIG91dDoKIAly
ZXR1cm4gc2tiOwogbm9kYXRhOgotCXNrYl9oZWFkX3RvX3Bvb2woc2tiKTsKKwlrbWVtX2Nh
Y2hlX2ZyZWUoc2tidWZmX2hlYWRfY2FjaGUsIHNrYik7CiAJc2tiID0gTlVMTDsKIAlnb3Rv
IG91dDsKIH0KQEAgLTI1Nyw3ICsyMDksNyBAQAogdm9pZCBrZnJlZV9za2JtZW0oc3RydWN0
IHNrX2J1ZmYgKnNrYikKIHsKIAlza2JfcmVsZWFzZV9kYXRhKHNrYik7Ci0Jc2tiX2hlYWRf
dG9fcG9vbChza2IpOworCWttZW1fY2FjaGVfZnJlZShza2J1ZmZfaGVhZF9jYWNoZSwgc2ti
KTsKIH0KIAogLyoqCkBAIC0zMjcsMTMgKzI3OSwxMCBAQAogCiBzdHJ1Y3Qgc2tfYnVmZiAq
c2tiX2Nsb25lKHN0cnVjdCBza19idWZmICpza2IsIGludCBnZnBfbWFzaykKIHsKLQlzdHJ1
Y3Qgc2tfYnVmZiAqbiA9IHNrYl9oZWFkX2Zyb21fcG9vbCgpOworCXN0cnVjdCBza19idWZm
ICpuID0ga21lbV9jYWNoZV9hbGxvYyhza2J1ZmZfaGVhZF9jYWNoZSwgZ2ZwX21hc2spOwog
Ci0JaWYgKCFuKSB7Ci0JCW4gPSBrbWVtX2NhY2hlX2FsbG9jKHNrYnVmZl9oZWFkX2NhY2hl
LCBnZnBfbWFzayk7Ci0JCWlmICghbikKLQkJCXJldHVybiBOVUxMOwotCX0KKwlpZiAoIW4p
IAorCQlyZXR1cm4gTlVMTDsKIAogI2RlZmluZSBDKHgpIG4tPnggPSBza2ItPngKIApAQCAt
MTI0MCw3ICsxMTg5LDQgQEAKIAkJCQkJICAgICAgTlVMTCwgTlVMTCk7CiAJaWYgKCFza2J1
ZmZfaGVhZF9jYWNoZSkKIAkJcGFuaWMoImNhbm5vdCBjcmVhdGUgc2tidWZmIGNhY2hlIik7
Ci0KLQlmb3IgKGkgPSAwOyBpIDwgTlJfQ1BVUzsgaSsrKQotCQlza2JfcXVldWVfaGVhZF9p
bml0KCZza2JfaGVhZF9wb29sW2ldLmxpc3QpOwogfQotLS0gbGludXgvbmV0L2NvcmUvc3lz
Y3RsX25ldF9jb3JlLmMuMDMwNDI4CTIwMDMtMDMtMjQgMjM6MDA6MTguMDAwMDAwMDAwICsw
MTAwCisrKyBsaW51eC9uZXQvY29yZS9zeXNjdGxfbmV0X2NvcmUuYwkyMDAzLTA0LTI4IDE2
OjU5OjA1LjAwMDAwMDAwMCArMDIwMApAQCAtMjgsNyArMjgsNiBAQAogCiBleHRlcm4gaW50
IHN5c2N0bF9jb3JlX2Rlc3Ryb3lfZGVsYXk7CiBleHRlcm4gaW50IHN5c2N0bF9vcHRtZW1f
bWF4OwotZXh0ZXJuIGludCBzeXNjdGxfaG90X2xpc3RfbGVuOwogCiAjaWZkZWYgQ09ORklH
X05FVF9ESVZFUlQKIGV4dGVybiBjaGFyIHN5c2N0bF9kaXZlcnRfdmVyc2lvbltdOwpAQCAt
MTUwLDE0ICsxNDksNiBAQAogCQkubW9kZQkJPSAwNjQ0LAogCQkucHJvY19oYW5kbGVyCT0g
JnByb2NfZG9pbnR2ZWMKIAl9LAotCXsKLQkJLmN0bF9uYW1lCT0gTkVUX0NPUkVfSE9UX0xJ
U1RfTEVOR1RILAotCQkucHJvY25hbWUJPSAiaG90X2xpc3RfbGVuZ3RoIiwKLQkJLmRhdGEJ
CT0gJnN5c2N0bF9ob3RfbGlzdF9sZW4sCi0JCS5tYXhsZW4JCT0gc2l6ZW9mKGludCksCi0J
CS5tb2RlCQk9IDA2NDQsCi0JCS5wcm9jX2hhbmRsZXIJPSAmcHJvY19kb2ludHZlYwotCX0s
CiAjaWZkZWYgQ09ORklHX05FVF9ESVZFUlQKIAl7CiAJCS5jdGxfbmFtZQk9IE5FVF9DT1JF
X0RJVkVSVF9WRVJTSU9OLAo=

--VOhjG1twcL
Content-Type: text/plain; charset=us-ascii
Content-Description: message body text
Content-Transfer-Encoding: 7bit




 Vanilla slab. Input streams 2*534 kpps
======================================

           CPU0       CPU1       
 24:          9         65   IO-APIC-level  eth2
 25:      54545         13   IO-APIC-level  eth3
 26:         78          0   IO-APIC-level  eth0
 27:         23      62315   IO-APIC-level  eth1

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 3339339 8828613 8828613 6660669     33      0      0      0 BRU
eth1   1500   0     57      0      0      0 3339340      0      0      0 BRU
eth2   1500   0 3800145 8670213 8670213 6199858     27      0      0      0 BRU
eth3   1500   0      1      0      0      0 3800144      0      0      0 BRU

0032f44f 00000000 00002ffa 00000000 00000000 00000000 00000000 00000000 00000000
0039fc87 00000000 00003373 00000000 00000000 00000000 00000000 00000000 00000000

With slab magazine patch. Input streams 2*534 kpps
==================================================

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 3936399 8370562 8370562 6063606     31      0      0      0 BRU
eth1   1500   0     58      0      0      0 3936403      0      0      0 BRU
eth2   1500   0 4142687 8308862 8308862 5857316     27      0      0      0 BRU
eth3   1500   0      1      0      0      0 4142686      0      0      0 BRU

003c1090 00000000 000034d1 00000000 00000000 00000000 00000000 00000000 00000000
003f3699 00000000 00003722 00000000 00000000 00000000 00000000 00000000 00000000

           CPU0       CPU1       
 24:          9         81   IO-APIC-level  eth2
 25:      64461         14   IO-APIC-level  eth3
 26:         94          0   IO-APIC-level  eth0
 27:         20      67759   IO-APIC-level  eth1
Daemon started.
Profiler running.
Stopping profiling.
Cpu type: P4 / Xeon
Cpu speed was (MHz estimation) : 1799.59
Counter 0 counted GLOBAL_POWER_EVENTS events (time during which processor is not stopped) with a unit mask of 0x01 (count cycles when processor is active) count 180000
vma      samples  %-age       symbol name
c02152c0 89894    13.7456     alloc_skb
c022af44 69317    10.5992     ip_output
c021fd90 64410    9.84889     qdisc_restart
c01c8608 60224    9.20882     e1000_clean_tx_irq
c021fbb8 48501    7.41626     eth_type_trans
c021558c 42143    6.44406     skb_release_data
c02156e4 36162    5.52951     __kfree_skb
c01378b8 26285    4.01922     kmalloc
c022645c 25858    3.95393     ip_route_input
c01c87c0 23820    3.6423      e1000_clean_rx_irq
c01c76c8 23261    3.55683     e1000_xmit_frame
c0218a60 17677    2.70298     dev_queue_xmit
c01374e0 12685    1.93966     cache_alloc_refill
c0137a00 11319    1.73078     kfree
c010fda0 11077    1.69378     do_gettimeofday
c0228314 10202    1.55998     ip_rcv
c0114050 8899     1.36074     get_offset_tsc
c021567c 8394     1.28352     kfree_skbmem
c0229700 6794     1.03887     ip_forward
c01c8bf0 6531     0.998651    e1000_alloc_rx_buffers
c01c8554 6379     0.975409    e1000_clean
c021cadc 5234     0.800328    neigh_resolve_output
c02190f0 5106     0.780755    netif_receive_skb
c01c8468 4658     0.712252    e1000_intr
c0114068 3542     0.541605    mark_offset_tsc
c0222320 2156     0.329673    pfifo_dequeue
Cpu type: P4 / Xeon
Cpu speed was (MHz estimation) : 1799.59
Counter 7 counted MISPRED_BRANCH_RETIRED events (retired mispredicted branches) with a unit mask of 0x01 (retired instruction is non-bogus) count 18000
vma      samples  %-age       symbol name
c022af44 718      27.7113     ip_output
c021fd90 513      19.7993     qdisc_restart
c02156e4 360      13.8942     __kfree_skb
c01c8608 261      10.0733     e1000_clean_tx_irq
c0218a60 85       3.28059     dev_queue_xmit
c01c8bf0 85       3.28059     e1000_alloc_rx_buffers
c0137a00 53       2.04554     kfree
c01c87c0 50       1.92976     e1000_clean_rx_irq
c021558c 48       1.85257     skb_release_data
c01378b8 46       1.77538     kmalloc
c021fbb8 41       1.5824      eth_type_trans
c0222320 36       1.38942     pfifo_dequeue
c0228314 31       1.19645     ip_rcv
c01c76c8 30       1.15785     e1000_xmit_frame
c02152c0 24       0.926283    alloc_skb
c022645c 19       0.733308    ip_route_input
c01377d0 19       0.733308    cache_flusharray
c010c750 17       0.656117    do_IRQ
c01c8554 15       0.578927    e1000_clean
c01168b8 13       0.501737    end_level_ioapic_irq
c02190f0 12       0.463142    netif_receive_skb
c01374e0 12       0.463142    cache_alloc_refill
c0120eb0 11       0.424547    do_softirq
c0229700 10       0.385951    ip_forward
c01c8468 10       0.385951    e1000_intr
c01245e8 9        0.347356    run_timer_softirq


With slab magazine patch and skb_head_pool removed. Input streams 2*533 kpps
============================================================================

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 4070842 8257568 8257568 5929162     32      0      0      0 BRU
eth1   1500   0     60      0      0      0 4070844      0      0      0 BRU
eth2   1500   0 4097594 8285413 8285413 5902409     27      0      0      0 BRU
eth3   1500   0      1      0      0      0 4097593      0      0      0 BRU

003e1dc4 00000000 000036e4 00000000 00000000 00000000 00000000 00000000 00000000
003e866f 00000000 00003711 00000000 00000000 00000000 00000000 00000000 00000000

           CPU0       CPU1       
 24:          9        156   IO-APIC-level  eth2
 25:      66506          8   IO-APIC-level  eth3
 26:        170          0   IO-APIC-level  eth0
 27:         23      66807   IO-APIC-level  eth1
NMI:          0          0 
LOC:     357638     357637 
ERR:          0
MIS:          0

Daemon started.
Profiler running.
Stopping profiling.
Cpu type: P4 / Xeon
Cpu speed was (MHz estimation) : 1799.55
Counter 0 counted GLOBAL_POWER_EVENTS events (time during which processor is not stopped) with a unit mask of 0x01 (count cycles when processor is active) count 180000
vma      samples  %-age       symbol name
c02152c0 90698    12.1819     alloc_skb
c022adf4 81812    10.9884     ip_output
c021fc40 74295    9.97875     qdisc_restart
c01c8608 67518    9.06852     e1000_clean_tx_irq
c021fa68 55350    7.4342      eth_type_trans
c02154ec 45940    6.17032     skb_release_data
c02155f8 41834    5.61883     __kfree_skb
c01c87c0 31218    4.19297     e1000_clean_rx_irq
c022630c 29209    3.92314     ip_route_input
c01c76c8 27768    3.72959     e1000_xmit_frame
c01378b8 20298    2.72628     kmalloc
c0218910 19762    2.65428     dev_queue_xmit
c01374e0 14245    1.91328     cache_alloc_refill
c0137a00 13807    1.85445     kfree
c010fda0 13406    1.80059     do_gettimeofday
c0137874 12601    1.69247     kmem_cache_alloc
c02281c4 11403    1.53157     ip_rcv
c0114050 9854     1.32352     get_offset_tsc
c01379b8 8743     1.17429     kmem_cache_free
c01c8bf0 8369     1.12406     e1000_alloc_rx_buffers
c02295b0 7607     1.02172     ip_forward
c01c8554 6912     0.928368    e1000_clean
c01c8468 5636     0.756986    e1000_intr
c0218fa0 5413     0.727034    netif_receive_skb
c01d2194 4363     0.586006    ide_insw
c0114068 3972     0.533489    mark_offset_tsc
Cpu type: P4 / Xeon
Cpu speed was (MHz estimation) : 1799.55
Counter 7 counted MISPRED_BRANCH_RETIRED events (retired mispredicted branches) with a unit mask of 0x01 (retired instruction is non-bogus) count 18000
vma      samples  %-age       symbol name
c022adf4 766      26.3049     ip_output
c021fc40 617      21.1882     qdisc_restart
c02155f8 378      12.9808     __kfree_skb
c01c8608 298      10.2335     e1000_clean_tx_irq
c01c8bf0 120      4.12088     e1000_alloc_rx_buffers
c0218910 114      3.91484     dev_queue_xmit
c01c87c0 85       2.91896     e1000_clean_rx_irq
c0137a00 71       2.43819     kfree
c021fa68 42       1.44231     eth_type_trans
c02154ec 40       1.37363     skb_release_data
c01c76c8 39       1.33929     e1000_xmit_frame
c01378b8 31       1.06456     kmalloc
c02221d0 27       0.927198    pfifo_dequeue
c02295b0 23       0.789835    ip_forward
c02281c4 22       0.755495    ip_rcv
c02152c0 20       0.686813    alloc_skb
c01c8468 17       0.583791    e1000_intr
c01377d0 17       0.583791    cache_flusharray
c01c8554 16       0.549451    e1000_clean
c022630c 15       0.51511     ip_route_input
c01374e0 14       0.480769    cache_alloc_refill
c01168b8 13       0.446429    end_level_ioapic_irq
c010c750 10       0.343407    do_IRQ
c0114050 9        0.309066    get_offset_tsc
c0110074 9        0.309066    timer_interrupt
c02191f4 8        0.274725    net_rx_action
 
--VOhjG1twcL--
