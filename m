From: Marcin Gibula <m.gibula@gmail.com>
Subject: warning in 3.12.17 - skb_warn_bad_offload
Date: Wed, 23 Apr 2014 11:39:28 +0200
Message-ID: <CAGKO+35ZQ7-A9rtocWykdN_eLbOjXnJSam-UhAh45o7rrrWHpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:41627 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932122AbaDWJj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 05:39:29 -0400
Received: by mail-pb0-f45.google.com with SMTP id uo5so613125pbc.4
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 02:39:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've encountered following warnings with 3.12.17.
Interfaces are configured like that:

eth0 -> eth0.vlan ->
                          -> bond -> bridge  -> TUN (from virtual machine)
eth1 -> eth1.vlan ->

eth0/eth1 are Intel 10G (ixgbe driver). I tried turning gso/gro off on
all levels, with no difference.

Anything else I could try?

[829028.013203] WARNING: CPU: 9 PID: 4487 at net/core/dev.c:2218
skb_warn_bad_offload+0xc8/0xd5()
[829028.013840] : caps=(0x00000000000013a9, 0x0000000000000000)
len=1598 data_len=0 gso_size=1460 gso_type=5 ip_summed=0
[829028.014478] Modules linked in: ebt_dnat ebt_ip ebt_arp act_police
cls_u32 sch_ingress cls_fw sch_sfq sch_htb iptable_raw xt_CT
iptable_filter ebtable_nat ebtables iscsi_tcp libiscsi_tcp libiscsi
scsi_transport_iscsi x86_pkg_temp_thermal hpsa
[829028.015532] CPU: 9 PID: 4487 Comm: qemu-system-x86 Tainted: G
  W    3.12.17-gentoo #4
[829028.015855] Hardware name: HP ProLiant BL460c Gen8, BIOS I31 12/20/2013
[829028.016177]  0000000000000009 ffff8817dfc83b98 ffffffff81557bf8
ffff8817dfc83be0
[829028.016513]  ffff8817dfc83bd0 ffffffff81072623 ffff8817a3309100
ffff8817ba824000
[829028.016848]  0000000000000005 0000000000000000 ffffffff815c6800
ffff8817dfc83c30
[829028.017184] Call Trace:
[829028.017498]  <IRQ>  [<ffffffff81557bf8>] dump_stack+0x45/0x56
[829028.017841]  [<ffffffff81072623>] warn_slowpath_common+0x73/0x90
[829028.018160]  [<ffffffff81072687>] warn_slowpath_fmt+0x47/0x50
[829028.018488]  [<ffffffff8128b81c>] ? ___ratelimit+0x7c/0xf0
[829028.018809]  [<ffffffff81559f67>] skb_warn_bad_offload+0xc8/0xd5
[829028.019138]  [<ffffffff8147b581>] __skb_gso_segment+0x71/0xc0
[829028.019464]  [<ffffffff8147b89b>] dev_hard_start_xmit+0x19b/0x4a0
[829028.019786]  [<ffffffff8147bec2>] dev_queue_xmit+0x322/0x460
[829028.020111]  [<ffffffff815200b0>] ? br_forward_finish+0x60/0x60
[829028.020435]  [<ffffffff81520017>] br_dev_queue_push_xmit+0x87/0xc0
[829028.020757]  [<ffffffff8152006d>] br_forward_finish+0x1d/0x60
[829028.021078]  [<ffffffff81520106>] __br_forward+0x56/0xc0
[829028.021399]  [<ffffffff8151ff6e>] deliver_clone+0x2e/0x50
[829028.021720]  [<ffffffff81520539>] br_forward+0x39/0x60
[829028.022042]  [<ffffffff815212b1>] br_handle_frame_finish+0x201/0x310
[829028.022363]  [<ffffffff8152154d>] br_handle_frame+0x18d/0x250
[829028.022685]  [<ffffffff81478de2>] __netif_receive_skb_core+0x212/0x800
[829028.023005]  [<ffffffff814793e3>] __netif_receive_skb+0x13/0x60
[829028.023325]  [<ffffffff8147a658>] process_backlog+0x98/0x170
[829028.023651]  [<ffffffff8147a521>] net_rx_action+0x101/0x1a0
[829028.023970]  [<ffffffff81076489>] __do_softirq+0xd9/0x1a0
[829028.024290]  [<ffffffff81565afc>] call_softirq+0x1c/0x30
[829028.024607]  <EOI>  [<ffffffff81039225>] do_softirq+0x35/0x70
[829028.024938]  [<ffffffff81477d48>] netif_rx_ni+0x28/0x30
[829028.025261]  [<ffffffff813859d1>] tun_get_user+0x3f1/0x7f0
[829028.025580]  [<ffffffff81385ecb>] tun_chr_aio_write+0x7b/0xa0
[829028.025902]  [<ffffffff811396d7>] do_sync_readv_writev+0x47/0x80
[829028.026225]  [<ffffffff8113a9bf>] do_readv_writev+0xcf/0x230
[829028.026551]  [<ffffffff81173161>] ? fsnotify+0x231/0x310
[829028.026872]  [<ffffffff810d1eab>] ? __secure_computing+0x6b/0x1d0
[829028.027195]  [<ffffffff8113aba0>] vfs_writev+0x30/0x60
[829028.027519]  [<ffffffff8113acb4>] SyS_writev+0x44/0xa0
[829028.027844]  [<ffffffff81564ad9>] tracesys+0xd0/0xd5
[829028.028167] ---[ end trace 11d4549ee4aa78ec ]---


-- 
mg
