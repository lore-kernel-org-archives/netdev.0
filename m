From: Andrew Holway <a.holway@syseleven.de>
Subject: Getting VLANS to the vm ping / UDP working but TCP not
Date: Tue, 21 Aug 2012 16:03:53 +0200
Message-ID: <32989F47-00DD-4211-A570-229DA46A8FDC__15515.2211933911$1345564720$gmane$org@syseleven.de>
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: kvm@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kms.syseleven.de ([176.74.58.26]:56012 "EHLO kms.syseleven.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757716Ab2HUP61 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 11:58:27 -0400
Received: from [IPv6:::1] ([37.44.1.226])
	(authenticated user a.holway@syseleven.de)
	by kms.syseleven.de
	(using TLSv1/SSLv3 with cipher AES128-SHA (128 bits))
	for netdev@vger.kernel.org;
	Tue, 21 Aug 2012 17:28:23 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying out a couple of methods to get VLANs to the VM. In both cas=
es the VM can ping google et all without problem and DNS works fine but=
 it does not want to do any TCP. I thought this might be a frame size p=
roblem but even using telnet (which I understand sends tiny packets) fa=
ils to work.

Why would udp / ping work fine when tcp fails?

I saw some kind of weird packet on the bridge when I was trying to conn=
ect to a web server running on the VM with telnet.

15:11:47.464656 01:00:00:0e:00:24 (oui Unknown) > 00:00:01:00:00:00 (ou=
i Unknown), ethertype Unknown (0xdcd9), length 66:=20
	0x0000:  84a8 0800 4510 0030 cd23 4000 4006 527b  ....E..0.#@.@.R{
	0x0010:  257b 6811 257b 6812 f487 0050 da75 1e54  %{h.%{h....P.u.T
	0x0020:  0000 0000 7002 ffff 7b65 0000 0204 05b4  ....p...{e......
	0x0030:  0402 0000

But its hard to repeat them.

Any ideas?

Thanks,

Andrew


a) vm001 is on node002 and has the following xml:

[root@node002 ~]# virsh dumpxml vm001
=2E..
   <interface type=3D'bridge'>
     <mac address=3D'00:00:00:00:00:0e'/>
     <source bridge=3D'br0'/>
     <target dev=3D'vnet0'/>
     <alias name=3D'net0'/>
     <address type=3D'pci' domain=3D'0x0000' bus=3D'0x00' slot=3D'0x03'=
 function=3D'0x0'/>
   </interface>
   <interface type=3D'bridge'>
     <mac address=3D'00:00:01:00:00:0e'/>
     <source bridge=3D'br1'/>
     <target dev=3D'vnet1'/>
     <model type=3D'e1000'/>
     <alias name=3D'net1'/>
     <address type=3D'pci' domain=3D'0x0000' bus=3D'0x00' slot=3D'0x04'=
 function=3D'0x0'/>
   </interface>
=85

[root@vm001 ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
   link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
   inet 127.0.0.1/8 scope host lo
   inet6 ::1/128 scope host=20
      valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast st=
ate UP qlen 1000
   link/ether 00:00:00:00:00:0e brd ff:ff:ff:ff:ff:ff
   inet 10.141.100.1/16 brd 10.141.255.255 scope global eth0
   inet6 fe80::200:ff:fe00:e/64 scope link=20
      valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast st=
ate UP qlen 1000
   link/ether 00:00:01:00:00:0e brd ff:ff:ff:ff:ff:ff

###
4: eth1.4@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueu=
e state UP=20
   link/ether 00:00:01:00:00:0e brd ff:ff:ff:ff:ff:ff
   inet 37.123.104.18/29 brd 37.123.104.23 scope global eth1.4
   inet6 fe80::200:1ff:fe00:e/64 scope link=20
      valid_lft forever preferred_lft forever
###


[root@node002 ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
   link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
   inet 127.0.0.1/8 scope host lo
   inet6 ::1/128 scope host=20
      valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state UNKNOWN qlen =
1000
   link/ether 00:02:c9:34:67:31 brd ff:ff:ff:ff:ff:ff
   inet 192.168.0.1/24 scope global eth0
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP q=
len 1000
   link/ether 00:9c:02:24:1a:e0 brd ff:ff:ff:ff:ff:ff
   inet6 fe80::29c:2ff:fe24:1ae0/64 scope link=20
      valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1522 qdisc mq st=
ate UP qlen 1000
   link/ether 00:9c:02:24:1a:e4 brd ff:ff:ff:ff:ff:ff
   inet6 fe80::29c:2ff:fe24:1ae4/64 scope link=20
      valid_lft forever preferred_lft forever
5: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state =
UNKNOWN=20
   link/ether 00:9c:02:24:1a:e0 brd ff:ff:ff:ff:ff:ff
   inet 10.141.0.2/16 brd 10.141.255.255 scope global br0
   inet6 fe80::29c:2ff:fe24:1ae0/64 scope link=20
      valid_lft forever preferred_lft forever
7: br1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1522 qdisc noqueue state =
UNKNOWN=20
   link/ether 00:9c:02:24:1a:e4 brd ff:ff:ff:ff:ff:ff
   inet6 fe80::29c:2ff:fe24:1ae4/64 scope link=20
      valid_lft forever preferred_lft forever
8: virbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue sta=
te UNKNOWN=20
   link/ether 52:54:00:81:84:9f brd ff:ff:ff:ff:ff:ff
   inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
9: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qle=
n 500
   link/ether 52:54:00:81:84:9f brd ff:ff:ff:ff:ff:ff
33: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast =
state UNKNOWN qlen 500
   link/ether fe:00:00:00:00:0e brd ff:ff:ff:ff:ff:ff
   inet6 fe80::fc00:ff:fe00:e/64 scope link=20
      valid_lft forever preferred_lft forever
34: vnet1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1522 qdisc pfifo_fast =
state UNKNOWN qlen 500
   link/ether fe:00:01:00:00:0e brd ff:ff:ff:ff:ff:ff
   inet6 fe80::fc00:1ff:fe00:e/64 scope link=20
      valid_lft forever preferred_lft forever

[root@node002 ~]# sysctl -a | grep tcp
fs.nfs.nlm_tcpport =3D 0
fs.nfs.nfs_callback_tcpport =3D 0
net.netfilter.nf_conntrack_tcp_timeout_syn_sent =3D 120
net.netfilter.nf_conntrack_tcp_timeout_syn_recv =3D 60
net.netfilter.nf_conntrack_tcp_timeout_established =3D 432000
net.netfilter.nf_conntrack_tcp_timeout_fin_wait =3D 120
net.netfilter.nf_conntrack_tcp_timeout_close_wait =3D 60
net.netfilter.nf_conntrack_tcp_timeout_last_ack =3D 30
net.netfilter.nf_conntrack_tcp_timeout_time_wait =3D 120
net.netfilter.nf_conntrack_tcp_timeout_close =3D 10
net.netfilter.nf_conntrack_tcp_timeout_max_retrans =3D 300
net.netfilter.nf_conntrack_tcp_timeout_unacknowledged =3D 300
net.netfilter.nf_conntrack_tcp_loose =3D 1
net.netfilter.nf_conntrack_tcp_be_liberal =3D 0
net.netfilter.nf_conntrack_tcp_max_retrans =3D 3
net.ipv4.tcp_timestamps =3D 1
net.ipv4.tcp_window_scaling =3D 1
net.ipv4.tcp_sack =3D 1
net.ipv4.tcp_retrans_collapse =3D 1
net.ipv4.tcp_syn_retries =3D 5
net.ipv4.tcp_synack_retries =3D 5
net.ipv4.tcp_max_orphans =3D 262144
net.ipv4.tcp_max_tw_buckets =3D 262144
net.ipv4.tcp_keepalive_time =3D 1800
net.ipv4.tcp_keepalive_probes =3D 9
net.ipv4.tcp_keepalive_intvl =3D 75
net.ipv4.tcp_retries1 =3D 3
net.ipv4.tcp_retries2 =3D 15
net.ipv4.tcp_fin_timeout =3D 30
net.ipv4.tcp_syncookies =3D 0
net.ipv4.tcp_tw_recycle =3D 0
net.ipv4.tcp_abort_on_overflow =3D 0
net.ipv4.tcp_stdurg =3D 0
net.ipv4.tcp_rfc1337 =3D 0
net.ipv4.tcp_max_syn_backlog =3D 2048
net.ipv4.tcp_orphan_retries =3D 0
net.ipv4.tcp_fack =3D 1
net.ipv4.tcp_reordering =3D 3
net.ipv4.tcp_ecn =3D 2
net.ipv4.tcp_dsack =3D 1
net.ipv4.tcp_mem =3D 12397248	16529664	24794496
net.ipv4.tcp_wmem =3D 4096	16384	4194304
net.ipv4.tcp_rmem =3D 4096	87380	4194304
net.ipv4.tcp_app_win =3D 31
net.ipv4.tcp_adv_win_scale =3D 2
net.ipv4.tcp_tw_reuse =3D 0
net.ipv4.tcp_frto =3D 2
net.ipv4.tcp_frto_response =3D 0
net.ipv4.tcp_low_latency =3D 0
net.ipv4.tcp_no_metrics_save =3D 0
net.ipv4.tcp_moderate_rcvbuf =3D 1
net.ipv4.tcp_tso_win_divisor =3D 3
net.ipv4.tcp_congestion_control =3D cubic
net.ipv4.tcp_abc =3D 0
net.ipv4.tcp_mtu_probing =3D 0
net.ipv4.tcp_base_mss =3D 512
net.ipv4.tcp_workaround_signed_windows =3D 0
net.ipv4.tcp_dma_copybreak =3D 262144
net.ipv4.tcp_slow_start_after_idle =3D 1
net.ipv4.tcp_available_congestion_control =3D cubic reno
net.ipv4.tcp_allowed_congestion_control =3D cubic reno
net.ipv4.tcp_max_ssthresh =3D 0
net.ipv4.tcp_thin_linear_timeouts =3D 0
net.ipv4.tcp_thin_dupack =3D 0
sunrpc.transports =3D tcp 1048576
sunrpc.transports =3D tcp-bc 1048576
sunrpc.tcp_slot_table_entries =3D 2
sunrpc.tcp_max_slot_table_entries =3D 65536
sunrpc.tcp_fin_timeout =3D 15
