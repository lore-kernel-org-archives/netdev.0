From: Dave Jones <davej@redhat.com>
Subject: rds trying an oversized kmalloc
Date: Mon, 8 Jul 2013 21:14:34 -0400
Message-ID: <20130709011434.GA17426@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1381 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245Ab3GIBOq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jul 2013 21:14:46 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r691EknY022983
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 8 Jul 2013 21:14:46 -0400
Received: from gelk.kernelslacker.org (ovpn-113-62.phx2.redhat.com [10.3.113.62])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r691EbrU006444
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 8 Jul 2013 21:14:45 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.7/8.14.5) with ESMTP id r691EZVH017480
	for <netdev@vger.kernel.org>; Mon, 8 Jul 2013 21:14:35 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.7/8.14.7/Submit) id r691EYC5017479
	for netdev@vger.kernel.org; Mon, 8 Jul 2013 21:14:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WARNING: at mm/page_alloc.c:2411 __alloc_pages_nodemask+0xa3a/0xac0()
Modules linked in: sctp libcrc32c dccp_ipv6 dccp_ipv4 dccp dlci 8021q garp bridge stp snd_seq_dummy fuse bnep hidp tun rfcomm nfnetlink ipt_ULOG can_bcm scsi_transport_iscsi caif_socket caif irda crc_ccitt pppoe pppox ppp_generic slhc can_raw can rds nfc netrom bluetooth rfkill atm af_rxrpc llc2 x25 af_802154 ipx p8023 p8022 appletalk psnap llc phonet af_key rose ax25 snd_hda_codec_realtek snd_hda_codec_hdmi snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_page_alloc snd_timer e1000e snd ptp pps_core soundcore pcspkr
CPU: 2 PID: 12334 Comm: trinity-child35 Not tainted 3.10.0+ #23 
 ffffffff81a25556 ffff8801140119e0 ffffffff816f2bfd 0000000000000000
 ffff880114011a18 ffffffff8104d251 0000000000000000 0000000000000002
 0000000000000000 0000000000000000 000000000010c0d0 ffff880114011a28
Call Trace:
 [<ffffffff816f2bfd>] dump_stack+0x4e/0x82
 [<ffffffff8104d251>] warn_slowpath_common+0x61/0x80
 [<ffffffff8104d32a>] warn_slowpath_null+0x1a/0x20
 [<ffffffff8115a06a>] __alloc_pages_nodemask+0xa3a/0xac0
 [<ffffffff811a03ac>] ? set_track+0x8c/0x110
 [<ffffffff811a0e9d>] ? init_object+0x3d/0x70
 [<ffffffff810c9ed2>] ? __module_text_address+0x12/0x60
 [<ffffffff81197649>] alloc_pages_current+0xa9/0x170
 [<ffffffff81154a94>] __get_free_pages+0x14/0x50
 [<ffffffff811a46a3>] kmalloc_order_trace+0x33/0x1a0
 [<ffffffff815a5ec4>] ? release_sock+0x34/0x1f0
 [<ffffffff811a5932>] __kmalloc+0x362/0x370
 [<ffffffff810bc30d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff81055fe8>] ? local_bh_enable_ip+0x78/0xf0
 [<ffffffffa040b774>] rds_message_alloc+0x34/0xc0 [rds]
 [<ffffffffa040dfdd>] rds_sendmsg+0x25d/0x9b0 [rds]
 [<ffffffff81322bae>] ? debug_object_activate+0xbe/0x1e0
 [<ffffffff815a1bf9>] sock_sendmsg+0x99/0xd0
 [<ffffffff81322bae>] ? debug_object_activate+0xbe/0x1e0
 [<ffffffff815a2154>] SYSC_sendto+0x124/0x1d0
 [<ffffffff816fcb51>] ? _raw_spin_unlock+0x31/0x60
 [<ffffffff81095f69>] ? vtime_account_user+0x69/0x70
 [<ffffffff810bc30d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff81010088>] ? syscall_trace_enter+0x18/0x290
 [<ffffffff815a323e>] SyS_sendto+0xe/0x10
 [<ffffffff81705b94>] tracesys+0xdd/0xe2
---[ end trace be82bf697fe16de9 ]---


2410         if (order >= MAX_ORDER) {
2411                 WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
2412                 return NULL;
2413         }
