From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH v8 34/50] vhost/net: virtio 1.0 byte swap
Date: Tue, 06 Jan 2015 16:55:30 -0700
Message-ID: <1420588530.3541.116.camel@redhat.com>
References: <1417449619-24896-1-git-send-email-mst@redhat.com>
	 <1417449619-24896-35-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	cornelia.huck@de.ibm.com, rusty@au1.ibm.com, nab@linux-iscsi.org,
	pbonzini@redhat.com, thuth@linux.vnet.ibm.com,
	dahi@linux.vnet.ibm.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42964 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751667AbbAFXzp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 18:55:45 -0500
In-Reply-To: <1417449619-24896-35-git-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-12-01 at 18:05 +0200, Michael S. Tsirkin wrote:
> I had to add an explicit tag to suppress compiler warning:
> gcc isn't smart enough to notice that
> len is always initialized since function is called with size > 0.

I'm getting a panic inside a guest when this change is applied on the
host.  I identified this patch via bisect and confirmed by reverting it
from v3.19-rc2.  Guest is centos6.  Thanks,

Alex

commit 8b38694a2dc8b18374310df50174f1e4376d6824
Author: Michael S. Tsirkin <mst@redhat.com>
Date:   Fri Oct 24 14:19:48 2014 +0300

    vhost/net: virtio 1.0 byte swap
    
    I had to add an explicit tag to suppress compiler warning:
    gcc isn't smart enough to notice that
    len is always initialized since function is called with size > 0.
    
    Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
    Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>

XML chunk:

    <interface type='direct'>
      <mac address='52:54:00:64:f3:34'/>
      <source dev='iscsinet0' mode='bridge'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>

Panic log:

<1>BUG: unable to handle kernel NULL pointer dereference at 0000000000000010
<1>IP: [<ffffffffa0079469>] virtnet_poll+0x4f9/0x910 [virtio_net]
<4>PGD 1aa2f4067 PUD 1aa2f5067 PMD 0 
<4>Oops: 0000 [#1] SMP 
<4>last sysfs file: /sys/devices/pci0000:00/0000:00:03.0/virtio0/net/eth9/ifindex
<4>CPU 0 
<4>Modules linked in: 8021q garp stp llc ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables ipv6 uinput microcode snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_timer snd soundcore snd_page_alloc igbvf nvidia(P)(U) i2c_core tg3 ptp pps_core virtio_balloon virtio_net virtio_console ext4 jbd2 mbcache virtio_blk virtio_pci virtio_ring virtio pata_acpi ata_generic ata_piix dm_mirror dm_region_hash dm_log dm_mod [last unloaded: speedstep_lib]
<4>
<4>Pid: 1374, comm: NetworkManager Tainted: P           ---------------    2.6.32-431.23.3.el6.centos.plus.x86_64 #1 QEMU Standard PC (i440FX + PIIX, 1996)
<4>RIP: 0010:[<ffffffffa0079469>]  [<ffffffffa0079469>] virtnet_poll+0x4f9/0x910 [virtio_net]
<4>RSP: 0018:ffff880028203e48  EFLAGS: 00010246
<4>RAX: ffff8801a3383d00 RBX: ffff8801a6aaf480 RCX: ffff8801aa20b6e0
<4>RDX: 00000000000000c0 RSI: ffff8801a3383c00 RDI: ffff8801a3383cc0
<4>RBP: ffff880028203ed8 R08: 000000000000009e R09: ffff8801aa1d800c
<4>R10: 0000000000000218 R11: 0000000000000000 R12: ffff8801aa20b6e0
<4>R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
<4>FS:  00007febf114d800(0000) GS:ffff880028200000(0000) knlGS:0000000000000000
<4>CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>CR2: 0000000000000010 CR3: 00000001aa793000 CR4: 00000000000006f0
<4>DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>Process NetworkManager (pid: 1374, threadinfo ffff8801a74ba000, task ffff8801a8d56040)
<4>Stack:
<4> ffff8801aa1d8000 000000000000009e ffff8801aa20b6e0 ffff8801aa20b718
<4><d> ffff8801aa20b780 ffff8801aa1d800c ffff8801a6aaf4b8 ffff8801aa20b020
<4><d> 0000000000000080 ffff8801aa20b708 0000000000000001 00001f5981a830c8
<4>Call Trace:
<4> <IRQ> 
<4> [<ffffffff8146ae33>] net_rx_action+0x103/0x2f0
<4> [<ffffffff8107a5f1>] __do_softirq+0xc1/0x1e0
<4> [<ffffffff8100c30c>] ? call_softirq+0x1c/0x30
<4> [<ffffffff8100c30c>] call_softirq+0x1c/0x30
<4> <EOI> 
<4> [<ffffffff8100fa75>] ? do_softirq+0x65/0xa0
<4> [<ffffffff8107b2ea>] local_bh_enable+0x9a/0xb0
<4> [<ffffffffa007813a>] virtnet_napi_enable+0x4a/0x60 [virtio_net]
<4> [<ffffffffa0078ebf>] virtnet_open+0x4f/0x60 [virtio_net]
<4> [<ffffffff81467691>] dev_open+0xa1/0x100
<4> [<ffffffff81466751>] dev_change_flags+0xa1/0x1d0
<4> [<ffffffff81474a59>] do_setlink+0x169/0x8b0
<4> [<ffffffff814770b6>] ? rtnl_fill_ifinfo+0x946/0xcb0
<4> [<ffffffff812a3d24>] ? nla_parse+0x34/0x110
<4> [<ffffffff8147659e>] rtnl_setlink+0xee/0x130
<4> [<ffffffff81475b67>] rtnetlink_rcv_msg+0x2d7/0x340
<4> [<ffffffff81231e14>] ? socket_has_perm+0x74/0x90
<4> [<ffffffff81475890>] ? rtnetlink_rcv_msg+0x0/0x340
<4> [<ffffffff814910a9>] netlink_rcv_skb+0xa9/0xd0
<4> [<ffffffff81475875>] rtnetlink_rcv+0x25/0x40
<4> [<ffffffff81490cdb>] netlink_unicast+0x2db/0x320
<4> [<ffffffff81491750>] netlink_sendmsg+0x2c0/0x3d0
<4> [<ffffffff814520c3>] sock_sendmsg+0x123/0x150
<4> [<ffffffff81453d73>] ? sock_recvmsg+0x133/0x160
<4> [<ffffffff8109afa0>] ? autoremove_wake_function+0x0/0x40
<4> [<ffffffff81136941>] ? lru_cache_add_lru+0x21/0x40
<4> [<ffffffff8115522d>] ? page_add_new_anon_rmap+0x9d/0xf0
<4> [<ffffffff8114aeef>] ? handle_pte_fault+0x4af/0xb00
<4> [<ffffffff81451f14>] ? move_addr_to_kernel+0x64/0x70
<4> [<ffffffff814538b6>] __sys_sendmsg+0x406/0x420
<4> [<ffffffff8104a98c>] ? __do_page_fault+0x1ec/0x480
<4> [<ffffffff814523d9>] ? sys_sendto+0x139/0x190
<4> [<ffffffff8103ea6c>] ? kvm_clock_read+0x1c/0x20
<4> [<ffffffff81453ad9>] sys_sendmsg+0x49/0x90
<4> [<ffffffff8100b072>] system_call_fastpath+0x16/0x1b
<4>Code: 83 e0 00 00 00 00 10 00 00 48 03 93 d0 00 00 00 66 83 42 04 01 8b 93 cc 00 00 00 48 8b b3 d0 00 00 00 80 4c 16 10 20 44 2b 68 0c <4d> 8b 76 10 75 89 e9 d1 fd ff ff 0f 1f 40 00 a8 02 74 0d 0f b6 
<1>RIP  [<ffffffffa0079469>] virtnet_poll+0x4f9/0x910 [virtio_net]
<4> RSP <ffff880028203e48>
<4>CR2: 0000000000000010
