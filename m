From: Dave Jones <davej@redhat.com>
Subject: rds doesn't limit allocations from userspace.
Date: Fri, 1 Mar 2013 11:19:01 -0500
Message-ID: <20130301161901.GA27379@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: venkat.x.venkatsubra@oracle.com, rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2834 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779Ab3CAQTG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Mar 2013 11:19:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When fed mangled socket data, rds will trust what userspace gives it,
and tries to allocate enormous amounts of memory larger than what
kmalloc can satisfy.


WARNING: at mm/page_alloc.c:2393 __alloc_pages_nodemask+0xa0d/0xbe0()
Hardware name: GA-MA78GM-S2H
Modules linked in: vmw_vsock_vmci_transport vmw_vmci vsock fuse bnep dlci bridge 8021q garp stp mrp binfmt_misc l2tp_ppp l2tp_core rfcomm scsi_transport_iscsi nfnetlink hidp can_bcm can_raw rds rose appletalk ipt_ULOG atm af_rxrpc x25 pppoe pppox ipx af_key irda nfc phonet ppp_generic slhc caif_socket decnet caif crc_ccitt netrom ax25 llc2 can p8023 psnap p8022 llc lockd sunrpc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack nf_conntrack ip6table_filter ip6_tables snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_pcm btusb snd_page_alloc bluetooth microcode rfkill snd_timer usb_debug serio_raw pcspkr snd edac_core soundcore vhost_net r8169 tun macvtap mii macvlan kvm_amd kvm
Pid: 24652, comm: trinity-child2 Not tainted 3.8.0+ #65
Call Trace:
 [<ffffffff81044155>] warn_slowpath_common+0x75/0xa0
 [<ffffffff8104419a>] warn_slowpath_null+0x1a/0x20
 [<ffffffff811444ad>] __alloc_pages_nodemask+0xa0d/0xbe0
 [<ffffffff8100a196>] ? native_sched_clock+0x26/0x90
 [<ffffffff810b2128>] ? trace_hardirqs_off_caller+0x28/0xc0
 [<ffffffff810b21cd>] ? trace_hardirqs_off+0xd/0x10
 [<ffffffff811861f8>] alloc_pages_current+0xb8/0x180
 [<ffffffff8113eaaa>] __get_free_pages+0x2a/0x80
 [<ffffffff811934fe>] kmalloc_order_trace+0x3e/0x1a0
 [<ffffffff81193955>] __kmalloc+0x2f5/0x3a0
 [<ffffffff8104df0c>] ? local_bh_enable_ip+0x7c/0xf0
 [<ffffffffa0401ab3>] rds_message_alloc+0x23/0xb0 [rds]
 [<ffffffffa04043a1>] rds_sendmsg+0x2b1/0x990 [rds]
 [<ffffffff810b21cd>] ? trace_hardirqs_off+0xd/0x10
 [<ffffffff81564620>] sock_sendmsg+0xb0/0xe0
 [<ffffffff810b2052>] ? get_lock_stats+0x22/0x70
 [<ffffffff810b24be>] ? put_lock_stats.isra.23+0xe/0x40
 [<ffffffff81567f30>] sys_sendto+0x130/0x180
 [<ffffffff810b872d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff816c547b>] ? _raw_spin_unlock_irq+0x3b/0x60
 [<ffffffff816cd767>] ? sysret_check+0x1b/0x56
 [<ffffffff810b8695>] ? trace_hardirqs_on_caller+0x115/0x1a0
 [<ffffffff81341d8e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff816cd742>] system_call_fastpath+0x16/0x1b
---[ end trace eed6ae990d018c8b ]---
