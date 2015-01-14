From: Jeff Layton <jeff.layton@primarydata.com>
Subject: [ 2375.793397] WARNING: CPU: 0 PID: 1149 at
 net/netlink/genetlink.c:1037 genl_unbind+0xc0/0xd0()
Date: Wed, 14 Jan 2015 16:13:34 -0500
Message-ID: <20150114161334.28acf5fc@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:45953 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051AbbANVNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 16:13:45 -0500
Received: by mail-qg0-f45.google.com with SMTP id z107so8979277qgd.4
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 13:13:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While running the trinity fuzzer in a KVM guest, I ^C'ed it at an
(apparent) inopportune moment, and saw a bunch of these WARN_ONs pop:

[ 2375.793396] ------------[ cut here ]------------
[ 2375.793397] WARNING: CPU: 0 PID: 1149 at net/netlink/genetlink.c:1037 genl_unbind+0xc0/0xd0()
[ 2375.793417] Modules linked in: af_key crypto_user nfnetlink vmw_vsock_vmci_transport vmw_vmci vsock nfc af_802154 ieee802154 bluetooth rfkill pppoe pppox ppp_generic slhc irda crc_ccitt rds rose atm netrom appletalk ipx p8023 p8022 psnap ax25 ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw snd_hda_codec_generic snd_hda_intel snd_hda_controller snd_hda_codec snd_hwdep snd_pcm iosf_mbi crct10dif_pclmul snd_timer crc32_pclmul ppdev crc32c_intel snd ghash_clmulni_intel pa
 rport_pc joydev parport serio_raw pcspkr virtio_balloon soundcore virtio_console pvpanic i2c_piix4 virtio_blk virtio_net qxl drm_kms_helper ttm virtio_pci ata_generic virtio_ring drm pata_acpi virtio floppy
[ 2375.793424] CPU: 0 PID: 1149 Comm: trinity-main Tainted: G        W      3.19.0-rc4+ #26
[ 2375.793424] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140709_153950- 04/01/2014
[ 2375.793426]  0000000000000000 000000002a81588d ffff8800b932bd18 ffffffff8186adb8
[ 2375.793427]  0000000000000000 0000000000000000 ffff8800b932bd58 ffffffff810ac9da
[ 2375.793428]  ffffffff81f8c940 0000000000000000 ffffffff81f8c940 000000000000000f
[ 2375.793429] Call Trace:
[ 2375.793431]  [<ffffffff8186adb8>] dump_stack+0x4c/0x65
[ 2375.793432]  [<ffffffff810ac9da>] warn_slowpath_common+0x8a/0xc0
[ 2375.793433]  [<ffffffff810acb0a>] warn_slowpath_null+0x1a/0x20
[ 2375.793435]  [<ffffffff8175e580>] genl_unbind+0xc0/0xd0
[ 2375.793436]  [<ffffffff8175cbdd>] netlink_release+0x19d/0x3f0
[ 2375.793437]  [<ffffffff81700aaf>] sock_release+0x1f/0x90
[ 2375.793439]  [<ffffffff81700b32>] sock_close+0x12/0x20
[ 2375.793440]  [<ffffffff81275098>] __fput+0xf8/0x220
[ 2375.793441]  [<ffffffff8127520e>] ____fput+0xe/0x10
[ 2375.793443]  [<ffffffff810d29f4>] task_work_run+0xb4/0xe0
[ 2375.793444]  [<ffffffff810b040d>] do_exit+0x37d/0xcf0
[ 2375.793445]  [<ffffffff810b0e24>] do_group_exit+0x54/0xe0
[ 2375.793447]  [<ffffffff810b0ec4>] SyS_exit_group+0x14/0x20
[ 2375.793448]  [<ffffffff81874ff5>] tracesys_phase2+0xd4/0xd9
[ 2375.793449] ---[ end trace be07601dc6d6ab5c ]---

trinity was run with no arguments. I had it happen a couple of times
while running it, but it doesn't happen every time. It seems to be
somewhat contingent on signaling it at the right time.

-- 
Jeff Layton <jlayton@primarydata.com>
