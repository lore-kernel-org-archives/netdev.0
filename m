From: Vladimir Ivashchenko <hazard@francoudi.com>
Subject: 2.6.29.1 pktgen crash
Date: Wed, 20 May 2009 23:24:50 +0300
Message-ID: <20090520202450.GA12896@francoudi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gBBFr7Ir9EOA20Yy"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.thunderworx.net ([217.27.32.18]:2942 "EHLO
	cerber.thunderworx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755175AbZETUYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 16:24:51 -0400
Received: from hazard2.francoudi.com (localhost.localdomain [127.0.0.1])
	by mail.yourdomain.com (8.14.1/8.14.1) with ESMTP id n4KKOoW4012956
	for <netdev@vger.kernel.org>; Wed, 20 May 2009 23:24:50 +0300
Received: (from hazard@localhost)
	by hazard2.francoudi.com (8.14.1/8.14.1/Submit) id n4KKOo72012955
	for netdev@vger.kernel.org; Wed, 20 May 2009 23:24:50 +0300
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The attached script leads to a crash when you run it for 2-3 times on 2.6.29.1. The server still remains reachable, but starts misbehaving.

With 2.6.23.1, so far I didn't get any crashes.

May 20 21:09:03 tshape-phome2 kernel: BUG: unable to handle kernel paging request at f8bbc008
May 20 21:09:03 tshape-phome2 kernel: IP: [<f863ab01>] pktgen_remove_device+0x88/0xdc [pktgen]
May 20 21:09:03 tshape-phome2 kernel: *pde = 31030067 *pte = 00000000 
May 20 21:09:03 tshape-phome2 kernel: Oops: 0000 [#1] SMP 
May 20 21:09:03 tshape-phome2 kernel: last sysfs file: /sys/devices/platform/i5k_amb.0/name
May 20 21:09:03 tshape-phome2 kernel: Modules linked in: pktgen act_police cls_u32 sch_ingress autofs4 ip_vs rfcomm l2cap bluetooth bonding nf_conntrack_ipv6 xt_state nf_conntrack xt_tcpudp ip6t_ipv6header ip6t_REJECT ip6table_filter ip6_tables x_tables ipv6 dm_multipath joydev i5k_amb hwmon bnx2 sg e1000e ipmi_si i5000_edac edac_core sr_mod ehci_hcd ipmi_msghandler pcspkr serio_raw uhci_hcd iTCO_wdt iTCO_vendor_support cdrom hpwdt dm_snapshot dm_zero dm_mirror dm_region_hash dm_log dm_mod ext3 mbcache jbd ata_piix libata cciss sd_mod scsi_mod [last unloaded: microcode]
May 20 21:09:03 tshape-phome2 kernel: 
May 20 21:09:03 tshape-phome2 kernel: Pid: 495, comm: kpktgend_0 Not tainted (2.6.29.1-1hzd.fc8 #1) ProLiant DL360 G5
May 20 21:09:03 tshape-phome2 kernel: EIP: 0060:[<f863ab01>] EFLAGS: 00010286 CPU: 0
May 20 21:09:03 tshape-phome2 kernel: EIP is at pktgen_remove_device+0x88/0xdc [pktgen]
May 20 21:09:03 tshape-phome2 kernel: EAX: f8bbc000 EBX: f4e85000 ECX: f4121500 EDX: 00000000
May 20 21:09:03 tshape-phome2 kernel: ESI: 00100000 EDI: 00010000 EBP: f3011f10 ESP: f3011f04
May 20 21:09:03 tshape-phome2 kernel:  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
May 20 21:09:03 tshape-phome2 kernel: Process kpktgend_0 (pid: 495, ti=f3011000 task=f570e200 task.ti=f3011000)
May 20 21:09:03 tshape-phome2 kernel: Stack:
May 20 21:09:03 tshape-phome2 kernel:  ef9c9000 f4e85000 ef9c9004 f3011f24 f863ab8e ef9c9000 ef9c9000 ef9c9000
May 20 21:09:03 tshape-phome2 kernel:  f3011fd0 f863cba3 ef9c9000 e36f8a15 00046a5b f7eaa74a f41cad80 c065a4f6
May 20 21:09:03 tshape-phome2 kernel:  f3011f60 c065b365 00000286 c040272a 00000000 f416ef40 f4146e40 f3011f78
May 20 21:09:03 tshape-phome2 kernel: Call Trace:
May 20 21:09:03 tshape-phome2 kernel:  [<f863ab8e>] ? pktgen_rem_all_ifs+0x39/0x51 [pktgen]
May 20 21:09:03 tshape-phome2 kernel:  [<f863cba3>] ? pktgen_thread_worker+0x111e/0x1266 [pktgen]
May 20 21:09:03 tshape-phome2 kernel:  [<f7eaa74a>] ? bnx2_start_xmit+0x0/0x3c5 [bnx2]
May 20 21:09:03 tshape-phome2 kernel:  [<c065a4f6>] ? kretprobe_table_unlock+0x12/0x14
May 20 21:09:03 tshape-phome2 kernel:  [<c065b365>] ? kprobe_flush_task+0x58/0x5f
May 20 21:09:03 tshape-phome2 kernel:  [<c040272a>] ? __switch_to+0xde/0x168
May 20 21:09:03 tshape-phome2 kernel:  [<c0426c0f>] ? finish_task_switch+0x93/0xab
May 20 21:09:03 tshape-phome2 kernel:  [<c043d205>] ? autoremove_wake_function+0x0/0x33
May 20 21:09:03 tshape-phome2 kernel:  [<f863ba85>] ? pktgen_thread_worker+0x0/0x1266 [pktgen]
May 20 21:09:03 tshape-phome2 kernel:  [<c043d131>] ? kthread+0x3b/0x62
May 20 21:09:03 tshape-phome2 kernel:  [<c043d0f6>] ? kthread+0x0/0x62
May 20 21:09:03 tshape-phome2 kernel:  [<c0404193>] ? kernel_thread_helper+0x7/0x10
May 20 21:09:03 tshape-phome2 kernel: Code: 8b 03 85 c0 74 0e 8b 40 08 8b 15 7c 1a 64 f8 e8 fb f3 e8 c7 31 ff 31 f6 83 bb 44 02 00 00 00 75 36 eb 3c 8b 83 40 02 00 00 01 f0 <8b> 50 08 85 d2 74 21 f0 ff 4a 18 0f 94 c0 84 c0 74 07 89 d0 e8 
May 20 21:09:03 tshape-phome2 kernel: EIP: [<f863ab01>] pktgen_remove_device+0x88/0xdc [pktgen] SS:ESP 0068:f3011f04
May 20 21:09:03 tshape-phome2 kernel: ---[ end trace 2ad593a542263595 ]---

-- 
Best Regards
Vladimir Ivashchenko
Chief Technology Officer
PrimeTel, Cyprus - www.prime-tel.com

--gBBFr7Ir9EOA20Yy
Content-Type: application/x-sh
Content-Disposition: attachment; filename="pktgen.sh"
Content-Transfer-Encoding: quoted-printable

#! /bin/sh=0A=0Amodprobe pktgen=0A=0A=0Afunction pgset() {=0A    local resu=
lt=0A=0A    echo $1 > $PGDEV=0A    echo 1=0A=0A    result=3D`cat $PGDEV | f=
grep "Result: OK:"`=0A    if [ "$result" =3D "" ]; then=0A         cat $PGD=
EV | fgrep Result:=0A    fi=0A}=0A=0Afunction pg() {=0A    echo inject > $P=
GDEV=0A    cat $PGDEV=0A}=0A=0A# Config Start Here ------------------------=
-----------------------------------=0A=0A=0A# thread config=0A# Each CPU ha=
s own thread. Two CPU exammple. We add eth0, eth2 respectivly.=0A=0APGDEV=
=3D/proc/net/pktgen/kpktgend_0=0A  echo "Removing all devices"=0A pgset "re=
m_device_all" =0A  echo "Adding eth0"=0A pgset "add_device eth0" =0A  echo =
"Setting max_before_softirq 10000"=0A pgset "max_before_softirq 10000"=0A=
=0A=0A# device config=0A# delay 0=0A# We need to do alloc for every skb sin=
ce we cannot clone here.=0A=0ACLONE_SKB=3D"clone_skb 0"=0A# NIC adds 4 byte=
s CRC=0APKT_SIZE=3D"pkt_size 600"=0A=0A# COUNT 0 means forever=0A#COUNT=3D"=
count 0"=0ACOUNT=3D"count 100000000"=0A#COUNT=3D"count 1000"=0ADELAY=3D"del=
ay 3000"=0A=0APGDEV=3D/proc/net/pktgen/eth0=0A  echo "Configuring $PGDEV"=
=0A pgset "$COUNT"=0A pgset "$CLONE_SKB"=0A pgset "$PKT_SIZE"=0A pgset "$DE=
LAY"=0A # Random address with in the min-max range=0A pgset "flag IPDST_RND=
" =0A pgset "dst_min 10.0.0.0" =0A pgset "dst_max 10.0.255.255" =0A=0A # 8k=
 Concurrent flows at 4 pkts=0A #pgset "flows 8192" =0A pgset "flows 2048" =
=0A pgset "flowlen 4" =0A=0A pgset "dst_mac  00:1b:24:bd:e9:cc"=0A=0A# Time=
 to run=0APGDEV=3D/proc/net/pktgen/pgctrl=0A=0A echo "Running... ctrl^C to =
stop"=0A pgset "start" =0A echo "Done"=0A=0A# Result can be vieved in /proc=
/net/pktgen/eth0=0A=0A
--gBBFr7Ir9EOA20Yy--
