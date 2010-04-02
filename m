From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG] latest net-next-2.6 doesnt fly
Date: Fri, 02 Apr 2010 11:33:03 +0200
Message-ID: <1270200783.1989.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:43961 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752833Ab0DBJdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 05:33:07 -0400
Received: by bwz1 with SMTP id 1so1394284bwz.21
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 02:33:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On my 32bit dev machine (bnx2 + tg3)

Suspects :

commit 5acbbd428db47b12f137a8a2aa96b3c0a96b744e
(net: change illegal_highdma to use dma_mask)

[ 1946.979911] BUG: unable to handle kernel NULL pointer dereference at
000000b4
[ 1946.980046] IP: [<c12dd30a>] dev_queue_xmit+0x47a/0x6a0
[ 1946.980145] *pde = 00000000 
[ 1946.980228] Oops: 0000 [#61] PREEMPT SMP DEBUG_PAGEALLOC
[ 1946.980409] last sysfs
file: /sys/devices/system/cpu/cpu3/cpufreq/stats/time_in_state
[ 1946.982172] Modules linked in: xt_hashlimit ipmi_si ipmi_msghandler
hpilo bonding
[ 1946.982442] 
[ 1946.982493] Pid: 9887, comm: emonitor Tainted: G      D W
2.6.34-rc1-01558-gba0ad27-dirty #598 /ProLiant BL460c G1
[ 1946.982574] EIP: 0060:[<c12dd30a>] EFLAGS: 00010202 CPU: 4
[ 1946.982632] EIP is at dev_queue_xmit+0x47a/0x6a0
[ 1946.982687] EAX: d4cb8cb0 EBX: d4d0cf30 ECX: c1d69003 EDX: c233a240
[ 1946.982746] ESI: 00000000 EDI: eeba8800 EBP: d4f69ba8 ESP: d4f69b6c
[ 1946.982804]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[ 1946.982862] Process emonitor (pid: 9887, ti=d4f69000 task=d5ac65e0
task.ti=d4f69000)
[ 1946.982937] Stack:
[ 1946.982987]  d5ac65e0 c1046b27 eebeff24 d4f69b88 c1073810 c12e43d5
eebeff00 d4f69b90
[ 1946.983274] <0> c1d69003 00000000 00000000 00000001 d4d0cf30 eebeff00
eebeff24 d4f69bec
[ 1946.983639] <0> c12e43eb eebeff48 00000000 00000b84 0000000e 00000246
00000002 d4f69bf0
[ 1946.983857] Call Trace:
[ 1946.983857]  [<c1046b27>] ? local_bh_enable_ip+0x67/0xd0
[ 1946.983857]  [<c1073810>] ? trace_hardirqs_on_caller+0x20/0x190
[ 1946.983857]  [<c12e43d5>] ? neigh_resolve_output+0xd5/0x350
[ 1946.983857]  [<c12e43eb>] ? neigh_resolve_output+0xeb/0x350
[ 1946.983857]  [<c12f0008>] ? qdisc_create+0x98/0x340
[ 1946.983857]  [<c12eda50>] ? eth_header+0x0/0xb0
[ 1946.983857]  [<c130ddc4>] ? ip_finish_output2+0xc4/0x280
[ 1946.983857]  [<c12fe618>] ? nf_hook_slow+0x108/0x140
[ 1946.983857]  [<c130df80>] ? ip_finish_output+0x0/0x70
[ 1946.983857]  [<c130dfcc>] ? ip_finish_output+0x4c/0x70
[ 1946.983857]  [<c130e0a2>] ? ip_output+0xb2/0xd0
[ 1946.983857]  [<c130df80>] ? ip_finish_output+0x0/0x70
[ 1946.983857]  [<c130d47d>] ? ip_local_out+0x1d/0x30
[ 1946.983857]  [<c130d92d>] ? ip_queue_xmit+0x13d/0x380
[ 1946.983857]  [<c10b5434>] ? get_page_from_freelist+0x254/0x510
[ 1946.983857]  [<c12d0517>] ? __skb_clone+0x27/0xe0
[ 1946.983857]  [<c132136d>] ? tcp_transmit_skb+0x35d/0x7a0
[ 1946.983857]  [<c1323341>] ? tcp_write_xmit+0x1e1/0x980
[ 1946.983857]  [<c10c6de2>] ? might_fault+0x62/0xb0
[ 1946.983857]  [<c1323b15>] ? tcp_push_one+0x35/0x40
[ 1946.983857]  [<c1317e28>] ? tcp_sendmsg+0x898/0x910
[ 1946.983857]  [<c12ca08b>] ? sock_aio_write+0xfb/0x110
[ 1946.983857]  [<c10e370d>] ? do_sync_readv_writev+0x9d/0xe0
[ 1946.983857]  [<c10e35b0>] ? rw_copy_check_uvector+0x80/0xf0
[ 1946.983857]  [<c10e4431>] ? do_readv_writev+0xa1/0x1b0
[ 1946.983857]  [<c12c9f90>] ? sock_aio_write+0x0/0x110
[ 1946.983857]  [<c10e4950>] ? rcu_read_unlock+0x0/0x50
[ 1946.983857]  [<c10e4976>] ? rcu_read_unlock+0x26/0x50
[ 1946.983857]  [<c10e4a6b>] ? fget_light+0xcb/0xe0
[ 1946.983857]  [<c10e4585>] ? vfs_writev+0x45/0x60
[ 1946.983857]  [<c10e4676>] ? sys_writev+0x46/0x70
[ 1946.983857]  [<c1002e50>] ? sysenter_do_call+0x12/0x36
[ 1946.983857] Code: 84 1b fd ff ff 0f b7 c9 8b b7 34 03 00 00 85 c9 89
4d f0 0f 8e 07 fd ff ff 8b 50 2c 8b 0a c1 e9 1a 8b 0c cd c0 04 cb c1 89
4d e4 <8b> 8e b4 00 00 00 85 c9 0f 84 d5 fc ff ff 8b 31 89 75 e8 8b 49 
[ 1946.983857] EIP: [<c12dd30a>] dev_queue_xmit+0x47a/0x6a0 SS:ESP
0068:d4f69b6c
[ 1946.983857] CR2: 00000000000000b4
[ 1946.988377] ---[ end trace a6e77232ba4a3a41 ]---


