From: Dave Jones <davej@redhat.com>
Subject: rds doing huge allocations
Date: Fri, 11 Jan 2013 22:44:24 -0500
Message-ID: <20130112034424.GA21666@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20789 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754419Ab3ALDo2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 22:44:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WARNING: at mm/page_alloc.c:2372 __alloc_pages_nodemask+0x9bf/0xba0()
Hardware name: GA-MA78GM-S2H
Modules linked in: bnep fuse rfcomm hidp dlci 8021q garp bridge stp netrom caif_socket caif af_rxrpc af_key llc2 rose phonet binfmt_misc l2tp_ppp l2tp_core pppoe pppox ppp_generic slhc nfnetlink can_raw scsi_transport_iscsi can_bcm can appletalk ipt_ULOG ax25 decnet nfc irda atm rds crc_ccitt x25 ipx p8023 psnap p8022 llc lockd sunrpc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack nf_conntrack ip6table_filter ip6_tables btusb bluetooth snd_hda_codec_realtek snd_hda_intel usb_debug snd_hda_codec microcode rfkill snd_pcm serio_raw snd_page_alloc pcspkr snd_timer edac_core snd soundcore r8169 mii vhost_net tun macvtap macvlan kvm_amd kvm
Pid: 21055, comm: trinity-child1 Not tainted 3.8.0-rc3+ #51
Call Trace:
 [<ffffffff81044d5f>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff81044dba>] warn_slowpath_null+0x1a/0x20
 [<ffffffff8114138f>] __alloc_pages_nodemask+0x9bf/0xba0
 [<ffffffff810b2858>] ? trace_hardirqs_off_caller+0x28/0xc0
 [<ffffffff810b28fd>] ? trace_hardirqs_off+0xd/0x10
 [<ffffffff81182e88>] alloc_pages_current+0xb8/0x180
 [<ffffffff8113b7d1>] __get_free_pages+0x21/0x80
 [<ffffffff8118fb0e>] kmalloc_order_trace+0x3e/0x1a0
 [<ffffffff8104e2dc>] ? local_bh_enable_ip+0x7c/0xf0
 [<ffffffff8119073d>] __kmalloc+0x30d/0x3b0
 [<ffffffff810b8c6d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8104e2dc>] ? local_bh_enable_ip+0x7c/0xf0
 [<ffffffffa02ab703>] rds_message_alloc+0x23/0xb0 [rds]
 [<ffffffffa02ae001>] rds_sendmsg+0x2b1/0x990 [rds]
 [<ffffffff812cae15>] ? sock_has_perm+0x5/0x230
 [<ffffffff81547d50>] sock_sendmsg+0xb0/0xe0
 [<ffffffff810b2782>] ? get_lock_stats+0x22/0x70
 [<ffffffff810b2bee>] ? put_lock_stats.isra.23+0xe/0x40
 [<ffffffff8154b660>] sys_sendto+0x130/0x180
 [<ffffffff810b8c6d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8169f21b>] ? _raw_spin_unlock_irq+0x3b/0x60
 [<ffffffff816a7227>] ? sysret_check+0x1b/0x56
 [<ffffffff810b8bd5>] ? trace_hardirqs_on_caller+0x115/0x1a0
 [<ffffffff81334cce>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff816a7202>] system_call_fastpath+0x16/0x1b
---[ end trace 59e8c396ac893aa3 ]---

That's this..

2371         if (order >= MAX_ORDER) {
2372                 WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
2373                 return NULL;
2374         }

So 'order' had ended up being huge somehow, after trusting
whatever came in from userspace via sendmsg.

	Dave
