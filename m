From: Eric Wheeler <netdev@lists.ewheeler.net>
Subject: Slow VLAN-to-VLAN routing and many stacktraces of
 skb_warn_bad_offload+0xc3/0xd0()
Date: Sun, 22 Jun 2014 16:03:23 -0700
Message-ID: <1403478203.5498.94.camel@geekdesk.ewheeler.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:38914 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783AbaFVXDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2014 19:03:36 -0400
Received: from homiemail-a5.g.dreamhost.com (homie.mail.dreamhost.com [208.97.132.208])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 8BF9292BDF
	for <netdev@vger.kernel.org>; Sun, 22 Jun 2014 16:03:36 -0700 (PDT)
Received: from homiemail-a5.g.dreamhost.com (localhost [127.0.0.1])
	by homiemail-a5.g.dreamhost.com (Postfix) with ESMTP id 41FCC70406F
	for <netdev@vger.kernel.org>; Sun, 22 Jun 2014 16:03:26 -0700 (PDT)
Received: from [192.168.102.61] (c-24-21-156-83.hsd1.or.comcast.net [24.21.156.83])
	(using SSLv3 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: ewheeler@ewheeler.net)
	by homiemail-a5.g.dreamhost.com (Postfix) with ESMTPSA id CE350704063
	for <netdev@vger.kernel.org>; Sun, 22 Jun 2014 16:03:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

We are getting a large number of stack traces with skb_warn_bad_offload
in dmesg running 3.14.6.  If you believe this is fixed in a later
release, please let me know and I can test whatever later version you
propose:

[157134.549229] ------------[ cut here ]------------
[157134.549448] WARNING: CPU: 0 PID: 27273 at net/core/dev.c:2238 skb_warn_bad_offload+0xc3/0xd0()
[157134.549882] bna: caps=(0x0000000100114bb3, 0x0000000007db78e9) len=2665 data_len=1139 gso_size=1448 gso_type=1 ip_summed=3
[157134.550335] Modules linked in: vhost_net macvtap macvlan vhost tun dm_thin_pool dm_bio_prison dm_persistent_data dm_bufio mpt3sas mpt2sas scsi_transport_sas raid_class mptctl mptbase zram ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack ipt_REJECT xt_CHECKSUM iptable_mangle ebtable_nat ebtables drbd(OF) libcrc32c xt_comment iptable_filter ip_tables bnx2fc cnic uio fcoe libfcoe libfc 8021q bridge stp llc dummy ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables ipv6 ext3 jbd kvm_intel kvm bcache iTCO_wdt iTCO_vendor_support serio_raw pcspkr i2c_i801 i2c_core acpi_cpufreq lpc_ich mfd_core e1000e ptp pps_core bna sg ext4(F) jbd2(F) mbcache(F) sd_mod(F) crc_t10dif(F) crct10dif_common(F) ahci(F) libahci(F) 
 video(F) bfa(F) scsi_transport_fc(F) scsi_tgt(F) megaraid_sas(F) dm_mirror(F) dm_region_hash(F) dm_log(F) dm_mod(F)
[157134.559980] CPU: 0 PID: 27273 Comm: curl Tainted: GF       W  O 3.14.6 #1
[157134.560220] Hardware name: Supermicro X9SCL/X9SCM/X9SCL/X9SCM, BIOS 2.0c 10/17/2013
[157134.560649]  00000000000008be ffff8807a3c4f2f8 ffffffff8159c163 00000000000008be
[157134.561087]  ffff8807a3c4f348 ffff8807a3c4f338 ffffffff8105598c ffff8807a3c4f388
[157134.561537]  ffff8807e4c998c0 ffff88080ebf0000 ffff88080ebf0000 0000000000000000
[157134.561993] Call Trace:
[157134.562205]  [<ffffffff8159c163>] dump_stack+0x49/0x5e
[157134.562422]  [<ffffffff8105598c>] warn_slowpath_common+0x8c/0xc0
[157134.562642]  [<ffffffff81055a76>] warn_slowpath_fmt+0x46/0x50
[157134.562864]  [<ffffffff814d2db3>] skb_warn_bad_offload+0xc3/0xd0
[157134.563085]  [<ffffffff814d6b5e>] skb_checksum_help+0x19e/0x1c0
[157134.563305]  [<ffffffff814d94fa>] dev_hard_start_xmit+0x4ba/0x5e0
[157134.563526]  [<ffffffff814fa70e>] sch_direct_xmit+0xfe/0x1d0
[157134.563747]  [<ffffffff814d97f5>] __dev_queue_xmit+0x1d5/0x4b0
[157134.563971]  [<ffffffffa0530550>] ? deliver_clone+0x60/0x60 [bridge]
[157134.564192]  [<ffffffff814d9af0>] dev_queue_xmit+0x10/0x20
[157134.564413]  [<ffffffffa05305e2>] br_dev_queue_push_xmit+0x92/0xd0 [bridge]
[157134.564638]  [<ffffffffa0530af2>] br_forward_finish+0x22/0x60 [bridge]
[157134.564863]  [<ffffffffa0530b83>] __br_deliver+0x53/0x120 [bridge]
[157134.565085]  [<ffffffffa0530cc1>] br_deliver+0x71/0x80 [bridge]
[157134.565305]  [<ffffffffa052ea74>] br_dev_xmit+0x1c4/0x280 [bridge]
[157134.565529]  [<ffffffffa0530550>] ? deliver_clone+0x60/0x60 [bridge]
[157134.565770]  [<ffffffff814d93a5>] dev_hard_start_xmit+0x365/0x5e0
[157134.565991]  [<ffffffff814d9927>] __dev_queue_xmit+0x307/0x4b0
[157134.566212]  [<ffffffff814d9af0>] dev_queue_xmit+0x10/0x20
[157134.566431]  [<ffffffffa05539dd>] vlan_dev_hard_start_xmit+0x9d/0x130 [8021q]
[157134.566852]  [<ffffffff814d93a5>] dev_hard_start_xmit+0x365/0x5e0
[157134.567064]  [<ffffffff814d9927>] __dev_queue_xmit+0x307/0x4b0
[157134.567277]  [<ffffffffa0530550>] ? deliver_clone+0x60/0x60 [bridge]
[157134.567489]  [<ffffffff814d9af0>] dev_queue_xmit+0x10/0x20
[157134.567701]  [<ffffffffa05305e2>] br_dev_queue_push_xmit+0x92/0xd0 [bridge]
[157134.567916]  [<ffffffffa0530af2>] br_forward_finish+0x22/0x60 [bridge]
[157134.568131]  [<ffffffffa0530b83>] __br_deliver+0x53/0x120 [bridge]
[157134.568344]  [<ffffffffa0530cc1>] br_deliver+0x71/0x80 [bridge]
[157134.568565]  [<ffffffffa052ea74>] br_dev_xmit+0x1c4/0x280 [bridge]
[157134.568785]  [<ffffffff814d93a5>] dev_hard_start_xmit+0x365/0x5e0
[157134.569005]  [<ffffffffa06796f1>] ? ipv4_confirm+0x71/0x100 [nf_conntrack_ipv4]
[157134.569434]  [<ffffffff814d9927>] __dev_queue_xmit+0x307/0x4b0
[157134.569653]  [<ffffffff8151a1d0>] ? ip_build_and_send_pkt+0x220/0x220
[157134.569889]  [<ffffffff814d9af0>] dev_queue_xmit+0x10/0x20
[157134.570107]  [<ffffffff8151a41e>] ip_finish_output+0x24e/0x490
[157134.570331]  [<ffffffff8151a6b8>] ip_output+0x58/0x90
[157134.570553]  [<ffffffff815197d2>] ? __ip_local_out+0xa2/0xb0
[157134.570774]  [<ffffffff81519809>] ip_local_out+0x29/0x30
[157134.570993]  [<ffffffff81519d24>] ip_queue_xmit+0x144/0x3d0
[157134.571209]  [<ffffffff81531305>] tcp_transmit_skb+0x415/0x7d0
[157134.571430]  [<ffffffff810bed6e>] ? getnstimeofday+0xe/0x30
[157134.571646]  [<ffffffff81532d83>] tcp_write_xmit+0x1e3/0x600
[157134.571868]  [<ffffffff815339e2>] __tcp_push_pending_frames+0x32/0xd0
[157134.572088]  [<ffffffff81527f6c>] tcp_data_snd_check+0x3c/0xe0
[157134.572308]  [<ffffffff8152df39>] tcp_rcv_established+0x339/0x610
[157134.572527]  [<ffffffff8152f3cb>] ? tcp_init_tso_segs+0x3b/0x60
[157134.572745]  [<ffffffff81538769>] tcp_v4_do_rcv+0x169/0x270
[157134.572962]  [<ffffffff814c3a69>] __release_sock+0x79/0xf0
[157134.573179]  [<ffffffff814c3b0e>] release_sock+0x2e/0x90
[157134.573396]  [<ffffffff81524f95>] tcp_sendmsg+0x115/0xd80
[157134.573615]  [<ffffffff8154d3c5>] inet_sendmsg+0x45/0xb0
[157134.573851]  [<ffffffff81236c03>] ? selinux_socket_sendmsg+0x23/0x30
[157134.574075]  [<ffffffff814bc8dd>] sock_aio_write+0xfd/0x110
[157134.574292]  [<ffffffff81199cef>] do_sync_write+0x5f/0xa0
[157134.574511]  [<ffffffff81199f5d>] ? rw_verify_area+0x5d/0xe0
[157134.574726]  [<ffffffff8119bc51>] vfs_write+0x1d1/0x1e0
[157134.574940]  [<ffffffff8119bd4a>] SyS_write+0x5a/0xd0
[157134.575156]  [<ffffffff815abf79>] ia32_do_call+0x13/0x13
[157134.575372] ---[ end trace 8fe338efa5e49e56 ]---

Server hardware is a Xeon E3-1230v2 with 10gbe bna card.

We are using the following configuration:

brtrunk0: a linux Ethernet bridge, mtu=9000
   members: eth0 (10gbe bna adapter) attached to tagged vlans 10,102
            vnet0 (linux kvm vm router interface) 
  ip: none.  This bridge only carries tagged vlan frames.

vlanbr102: a linux Ethernet bridge, mtu=1500
  members: brtrunk0.102 (vlan 102 from above)
  ip: 192.168.102.201
  Other VMs will ultimately join this bridge for the 102 network.
  Currently this bridge is empty except for the hypervisor's IP.

Note that we had to "ethtool -K brtrunk0 txvlan off" because tagging of
the linux bridge was not working with the default txvlan=on setting.
(Is this a bug?)
	

The KVM virtual machine on vnet0 router with the interfaces: 
	eth0.10:  192.168.100.33/24  mtu=1500
	eth0.102: 192.168.102.110/24 mtu=1500

Performance between hosts on the 192.168.102.0/24 and 192.168.100.0/24
networks is limited to about 150mbit (using iperf) for some reason,
which is why we began investigating.  Ultimately this is what we wish to
resolve.

Note that the iperf between VM and switched network on both sides
approaches gigabit as expected, but routing across the vlan interfaces
within the KVM instance is very slow.

Hypervisor to guest is very fast: 
192.168.102.201 to 192.168.102.110: [  3]  0.0-10.0 sec  36.5 GBytes  31.4 Gbits/sec

Tests from my workstation working outward:
1. 192.168.102.61 to 192.168.102.201: [  3]  0.0-10.0 sec  1.09 GBytes   940 Mbits/sec
2. 192.168.102.61 to 192.168.102.110: [  3]  0.0-10.0 sec  1.09 GBytes   939 Mbits/sec
3. 192.168.102.61 to 192.168.100.33 : [  3]  0.0-10.0 sec  1.09 GBytes   939 Mbits/sec
4. 192.168.102.61 to 192.168.100.22 : [  3]  0.0-10.0 sec   184 MBytes   154 Mbits/sec ?!?!
5. 192.168.100.33 to 192.168.100.22 : [  3]  0.0-10.0 sec  1.06 GBytes   913 Mbits/sec


The 4th test is from an external host, through the KVM router VM, and to
an other external host past the linux router vm (iptables is empty).
This is the performance problem that we wish to resolve. 

Please let me know if you need any additional information or any other
tests that you would like preformed.  This server is not yet in
production.

-Eric



Other possibly useful information:

$ tracepath -n 192.168.100.22
 1:  192.168.102.61    0.054ms pmtu 1500
 1:  192.168.102.110   0.367ms 
 1:  192.168.102.110   0.326ms 
 2:  192.168.100.22    0.921ms reached

[root@hv2 ~]# ethtool -i eth0
driver: bna
version: 3.2.23.0
firmware-version: 3.2.3.0
bus-info: 0000:02:00.2
supports-statistics: yes
supports-test: no
supports-eeprom-access: yes
supports-register-dump: no
supports-priv-flags: no

[root@hv2 ~]# ethtool -c eth0
Coalesce parameters for eth0:
Adaptive RX: on  TX: off
stats-block-usecs: 0
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0

rx-usecs: 60
rx-frames: 0
rx-usecs-irq: 0
rx-frames-irq: 0

tx-usecs: 100
tx-frames: 12
tx-usecs-irq: 0
tx-frames-irq: 0

rx-usecs-low: 0
rx-frame-low: 0
tx-usecs-low: 0
tx-frame-low: 0

rx-usecs-high: 0
rx-frame-high: 0
tx-usecs-high: 0
tx-frame-high: 0

[root@hv2 ~]# ethtool -k eth0
Features for eth0:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: on
	tx-checksum-ip-generic: off [fixed]
	tx-checksum-ipv6: on
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: on [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]

[root@hv2 ~]# ethtool -k brtrunk0
Features for brtrunk0:
rx-checksumming: off [fixed]
tx-checksumming: on
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: on
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: on
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: on
	tx-tcp6-segmentation: on
udp-fragmentation-offload: on
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off [fixed]
tx-vlan-offload: off
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: on
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: on [fixed]
netns-local: on [fixed]
tx-gso-robust: off [requested on]
tx-fcoe-segmentation: off [requested on]
tx-gre-segmentation: on
tx-ipip-segmentation: on
tx-sit-segmentation: on
tx-udp_tnl-segmentation: on
tx-mpls-segmentation: on
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]

--
eWheeler Inc.
