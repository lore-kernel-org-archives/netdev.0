From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
 take 2
Date: Fri, 31 Aug 2007 13:59:50 -0700
Message-ID: <46D88146.9090401@hp.com>
References: <46D769C1.8090808@hp.com>	<20070830.220911.41008322.davem@davemloft.net>	<46D859D9.6030407@hp.com> <20070831.115706.97292718.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:54089 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932654AbXHaVAk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 17:00:40 -0400
In-Reply-To: <20070831.115706.97292718.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I managed to find iproute2 sources (they were debian lenny/testing 
2.6.20-1) and applied the patch, and figured-out how to add a host route 
back to one of my systems.  I then did a change to set rto_min to 300. 
I started a tcpdump and then a netperf, and then forces some 
retransmissions the old fashioned way - by pulling a cable :)  I then 
Ctrl-C'd netperf and at that point got this:

Unable to handle kernel NULL pointer dereference (address 0000000000000038)
swapper[0]: Oops 8813272891392 [1]
Modules linked in: ipv6 sg sr_mod cdrom dm_snapshot dm_mirror dm_mod 
loop button shpchp pci_hotplug joydev evdev ext3 jbd mbcache usb_storage 
usbhid hid ide_core mptspi mptscsih ehci_hcd cciss ohci_hcd mptbase 
scsi_transport_spi scsi_mod usbcore e1000 thermal processor fan

Pid: 0, CPU 3, comm:              swapper
psr : 0000101008026038 ifs : 8000000000000001 ip  : [<a000000100477600>] 
    Not tainted
ip is at tcp_rto_min+0x20/0x40
unat: 0000000000000000 pfs : 0000000000000307 rsc : 0000000000000003
rnat: e0000100f32917e0 bsps: e0000100f32917e8 pr  : 00000000000166a5
ldrs: 0000000000000000 ccv : 0000000000010001 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001004777f0 b6  : a000000100230700 b7  : a000000100452e40
f6  : 000000000000000000000 f7  : 1003e000000000002813f
f8  : 1003e00000000001c06e2 f9  : 1003e000000000000043f
f10 : 1003e00000000000fd24b f11 : 1003e0044b82fa09b5a53
r1  : a0000001009b2710 r2  : 0000000000000000 r3  : e0000100fd317b40
r8  : 0000000000000032 r9  : 000000000000012c r10 : 0000000000000003
r11 : e000000ff07b63a0 r12 : e0000100fd317b40 r13 : e0000100fd310000
r14 : 0000000000000000 r15 : 0000000000000038 r16 : 0000000000000068
r17 : e000000ff07b6380 r18 : fffffffffffffa58 r19 : 000000008d769671
r20 : 000000008d769c19 r21 : e000000ff07b62f0 r22 : 000000008d7712e1
r23 : e000000ff07b62ec r24 : e000000ff07b637c r25 : 000000000000012c
r26 : 0000000000000032 r27 : e000000ff07b6438 r28 : e000000ff07b5fc8
r29 : e000000ff215bd80 r30 : e000000ff07b60d0 r31 : e000000ff07b6250

Call Trace:
  [<a000000100013700>] show_stack+0x40/0xa0
                                 sp=e0000100fd317710 bsp=e0000100fd311310
  [<a000000100014000>] show_regs+0x840/0x880
                                 sp=e0000100fd3178e0 bsp=e0000100fd3112b8
  [<a0000001000351a0>] die+0x1a0/0x2a0
                                 sp=e0000100fd3178e0 bsp=e0000100fd311270
  [<a0000001000579d0>] ia64_do_page_fault+0x8d0/0xa00
                                 sp=e0000100fd3178e0 bsp=e0000100fd311220
  [<a00000010000b0c0>] ia64_leave_kernel+0x0/0x270
                                 sp=e0000100fd317970 bsp=e0000100fd311220
  [<a000000100477600>] tcp_rto_min+0x20/0x40
                                 sp=e0000100fd317b40 bsp=e0000100fd311218
  [<a0000001004777f0>] tcp_rtt_estimator+0x1d0/0x280
                                 sp=e0000100fd317b40 bsp=e0000100fd3111e0
  [<a000000100479110>] tcp_ack_saw_tstamp+0x50/0xc0
                                 sp=e0000100fd317b40 bsp=e0000100fd3111c0
  [<a00000010047d7a0>] tcp_ack+0x13c0/0x4380
                                 sp=e0000100fd317b40 bsp=e0000100fd311120
  [<a000000100486fa0>] tcp_rcv_state_process+0x1420/0x2100
                                 sp=e0000100fd317b60 bsp=e0000100fd3110d8
  [<a000000100498760>] tcp_v4_do_rcv+0x960/0xa80
                                 sp=e0000100fd317b60 bsp=e0000100fd311078
  [<a00000010049e830>] tcp_v4_rcv+0x19d0/0x1b20
                                 sp=e0000100fd317b70 bsp=e0000100fd311008
  [<a0000001004542f0>] ip_local_deliver+0x530/0x7c0
                                 sp=e0000100fd317b70 bsp=e0000100fd310fd0
  [<a000000100453cb0>] ip_rcv+0xe70/0xf80
                                 sp=e0000100fd317b80 bsp=e0000100fd310f98
  [<a0000001003fcb40>] netif_receive_skb+0xa20/0xb80
                                 sp=e0000100fd317ba0 bsp=e0000100fd310f50
  [<a000000213211c20>] e1000_clean_rx_irq+0x9e0/0xc00 [e1000]
                                 sp=e0000100fd317ba0 bsp=e0000100fd310e90
  [<a00000021320ce50>] e1000_clean+0x130/0x6e0 [e1000]
                                 sp=e0000100fd317ba0 bsp=e0000100fd310e38
  [<a0000001004034c0>] net_rx_action+0x1c0/0x540
                                 sp=e0000100fd317bb0 bsp=e0000100fd310df0
  [<a0000001000908f0>] __do_softirq+0xf0/0x240
                                 sp=e0000100fd317bc0 bsp=e0000100fd310d78
  [<a000000100090ab0>] do_softirq+0x70/0xc0
                                 sp=e0000100fd317bc0 bsp=e0000100fd310d18
  [<a000000100090ca0>] irq_exit+0x80/0xa0
                                 sp=e0000100fd317bc0 bsp=e0000100fd310d00
  [<a000000100010cc0>] ia64_handle_irq+0x2a0/0x2e0
                                 sp=e0000100fd317bc0 bsp=e0000100fd310cd0
  [<a00000010000b0c0>] ia64_leave_kernel+0x0/0x270
                                 sp=e0000100fd317bc0 bsp=e0000100fd310cd0
  [<a0000001000142d0>] default_idle+0x110/0x180
                                 sp=e0000100fd317d90 bsp=e0000100fd310c90
  [<a0000001000131b0>] cpu_idle+0x210/0x2e0
                                 sp=e0000100fd317e30 bsp=e0000100fd310c60
  [<a00000010063cf50>] start_secondary+0x4b0/0x4e0
                                 sp=e0000100fd317e30 bsp=e0000100fd310c20
  [<a00000010050ae00>] __kprobes_text_end+0x340/0x370
                                 sp=e0000100fd317e30 bsp=e0000100fd310c20
Kernel panic - not syncing: Aiee, killing interrupt handler!

Of course there isn't all that much code to tcp_rto_min:


+static u32 tcp_rto_min(struct sock *sk)
+{
+	struct dst_entry *dst = __sk_dst_get(sk);
+	u32 rto_min = TCP_RTO_MIN;
+
+	if (dst_metric_locked(dst, RTAX_RTO_MIN))
+		rto_min = dst->metrics[RTAX_RTO_MIN-1];
+	return rto_min;
+}
+

So, I went ahead and rebooted and started again:

hpcpc103:~# ./ip route add dev eth0 15.244.56.217
hpcpc103:~# ./ip route show
15.244.56.217 dev eth0  scope link
16.89.84.0/25 dev eth0  proto kernel  scope link  src 16.89.84.103
default via 16.89.84.1 dev eth0
hpcpc103:~# netperf -H tardy -l 30
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
tardy.cup.hp.com (15.244.56.217) port 0 AF_INET

hpcpc103:~# ./ip route change dev eth0 15.244.56.217 min_rto 300
Error: either "to" is duplicate, or "min_rto" is a garbage.
hpcpc103:~# ./ip route change dev eth0 15.244.56.217 rto_min 300
hpcpc103:~# ./ip route show
15.244.56.217 dev eth0  scope link  rto_min lock 1200ms
16.89.84.0/25 dev eth0  proto kernel  scope link  src 16.89.84.103
default via 16.89.84.1 dev eth0

300 became 1200

hpcpc103:~# ./ip route change dev eth0 15.244.56.217 rto_min 600
hpcpc103:~# ./ip route show
15.244.56.217 dev eth0  scope link  rto_min lock 2400ms
16.89.84.0/25 dev eth0  proto kernel  scope link  src 16.89.84.103
default via 16.89.84.1 dev eth0

600 became 2400 ms but that is window dressing at the moment.  Go ahead 
and run netperf and let it finish on its own:

hpcpc103:~# netperf -H tardy
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
tardy.cup.hp.com (15.244.56.217) port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

  32768  16384  16384    10.02      72.81
hpcpc103:~#

now try it and abort netperf in the middle:

hpcpc103:~# netperf -H tardy -l 30
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
tardy.cup.hp.com (15.244.56.217) port 0 AF_INET

hpcpc103:~#

hmm, didn't happen again.  Now try with some RTO's forced:

hpcpc103:~# netperf -H tardy -l 30
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
tardy.cup.hp.com (15.244.56.217) port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

  32768  16384  16384    30.02      32.69

still happy.  forced RTO's and abort:

hpcpc103:~# netperf -H tardy -l 30
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
tardy.cup.hp.com (15.244.56.217) port 0 AF_INET

hpcpc103:~#

ok still happy.  So the failure is at best intermittant.  One final 
thing - try adding the tcpudmp again:

hpcpc103:~# device eth0 entered promiscuous mode
audit(1188593799.036:2): dev=eth0 prom=256 old_prom=0 auid=4294967295
netperf -H tardy -l 30
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
tardy.cup.hp.com (15.244.56.217) port 0 AF_INET

hpcpc103:~#

still happy.  Sigh, so much for easily reproducing the panic :(

rick

that second tcpdump does show the rto_min being honored:

16:56:46.543603 IP tardy.cup.hp.com.52620 > hpcpc103.cup.hp.com.51691: . 
ack 29438433 win 32768 <nop,nop,timestamp 7997540 54018>
16:56:46.543608 IP hpcpc103.cup.hp.com.51691 > tardy.cup.hp.com.52620: . 
29438433:29454361(15928) ack 1 win 46 <nop,nop,timestamp 54018 7997540>
16:56:46.543613 IP hpcpc103.cup.hp.com.51691 > tardy.cup.hp.com.52620: P 
29454361:29470289(15928) ack 1 win 46 <nop,nop,timestamp 54018 7997540>
16:56:48.956342 IP hpcpc103.cup.hp.com.51691 > tardy.cup.hp.com.52620: . 
29438433:29439881(1448) ack 1 win 46 <nop,nop,timestamp 54622 7997540>
16:56:53.788276 IP hpcpc103.cup.hp.com.51691 > tardy.cup.hp.com.52620: . 
29438433:29439881(1448) ack 1 win 46 <nop,nop,timestamp 55830 7997540>
16:56:53.855520 IP tardy.cup.hp.com.52620 > hpcpc103.cup.hp.com.51691: . 
ack 29439881 win 32768 <nop,nop,timestamp 7998272 55830>
16:56:53.855526 IP hpcpc103.cup.hp.com.51691 > tardy.cup.hp.com.52620: . 
29439881:29441329(1448) ack 1 win 46 <nop,nop,timestamp 55846 7998272>
16:56:53.855530 IP hpcpc103.cup.hp.com.51691 > tardy.cup.hp.com.52620: . 
29441329:29442777(1448) ack 1 win 46 <nop,nop,timestamp 55846 7998272>
16:56:53.925505 IP tardy.cup.hp.com.52620 > hpcpc103.cup.hp.com.51691: . 
ack 29442777 win 32768 <nop,nop,timestamp 7998279 55846>
16:56:53.925511 IP hpcpc103.cup.hp.com.51691 > tardy.cup.hp.com.52620: . 
29442777:29444225(1448) ack 1 win 46 <nop,nop,timestamp 55864 7998279>
