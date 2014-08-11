From: Andrey Wagin <avagin@gmail.com>
Subject: linux-next: WARNING: CPU: 0 PID: 2825 at net/ipv4/tcp_input.c:3078 tcp_ack+0x11f5/0x1380()
Date: Mon, 11 Aug 2014 17:35:42 +0400
Message-ID: <CANaxB-x7UVwLUi6RwQ9fU_j-AB3jhBmFehis-+XVaHet4wmsLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, "criu@openvz.org" <criu@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f177.google.com ([209.85.220.177]:33667 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753398AbaHKNfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 09:35:43 -0400
Received: by mail-vc0-f177.google.com with SMTP id hy4so11333167vcb.8
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2014 06:35:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I execute CRIU tests on linux-next. Today I started to check the tain
flag and found a warning:

[  866.469685] Peer 127.0.0.1:46524/8880 unexpectedly shrunk window
2532634294:2557500938 (repaired)
[  879.562534] ------------[ cut here ]------------
[  879.562947] WARNING: CPU: 0 PID: 2825 at net/ipv4/tcp_input.c:3078
tcp_ack+0x11f5/0x1380()
[  879.563571] Modules linked in: tun netlink_diag af_packet_diag
udp_diag tcp_diag inet_diag unix_diag ip6t_rpfilter ip6t_REJECT
xt_conntrack cfg80211 rfkill ebtable_nat ebtable_broute bridge stp llc
ebtable_filter ebtables ppdev ip6table_nat nf_conntrack_ipv6
nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security
ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle
iptable_security iptable_raw microcode serio_raw i2c_piix4 parport_pc
parport nfsd auth_rpcgss nfs_acl lockd sunrpc virtio_blk virtio_net
virtio_pci virtio_ring virtio ata_generic pata_acpi
[  879.567253] CPU: 0 PID: 2825 Comm: socket-tcpbuf-l Not tainted
3.16.0-next-20140811 #1
[  879.567829] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  879.568177]  0000000000000000 00000000c532680c ffff880039643d00
ffffffff817aa2d2
[  879.568776]  0000000000000000 ffff880039643d38 ffffffff8109afbd
ffff880039d6ba80
[  879.569386]  ffff88003a449800 000000002983d6bd 0000000000000000
000000002983d6bc
[  879.569982] Call Trace:
[  879.570264]  [<ffffffff817aa2d2>] dump_stack+0x4d/0x66
[  879.570599]  [<ffffffff8109afbd>] warn_slowpath_common+0x7d/0xa0
[  879.570935]  [<ffffffff8109b0ea>] warn_slowpath_null+0x1a/0x20
[  879.571292]  [<ffffffff816d0a05>] tcp_ack+0x11f5/0x1380
[  879.571614]  [<ffffffff816d10bd>] tcp_rcv_established+0x1ed/0x710
[  879.571958]  [<ffffffff816dc9da>] tcp_v4_do_rcv+0x10a/0x370
[  879.572315]  [<ffffffff81657459>] release_sock+0x89/0x1d0
[  879.572642]  [<ffffffff816c81a0>] do_tcp_setsockopt.isra.36+0x120/0x860
[  879.573000]  [<ffffffff8110a52e>] ? rcu_read_lock_held+0x6e/0x80
[  879.573352]  [<ffffffff816c8912>] tcp_setsockopt+0x32/0x40
[  879.573678]  [<ffffffff81654ac4>] sock_common_setsockopt+0x14/0x20
[  879.574031]  [<ffffffff816537b0>] SyS_setsockopt+0x80/0xf0
[  879.574393]  [<ffffffff817b40a9>] system_call_fastpath+0x16/0x1b
[  879.574730] ---[ end trace a17cbc38eb8c5c00 ]---
[  893.880049] Peer 0000:0000:0000:0000:0000:0000:0000:0001:60450/8880
unexpectedly shrunk window 6341700:31207524 (repaired)

During tests a few tcp connections have been repaired. I think the
problem is around these sockets. I'm going to look what wrong here.
