From: Chris Stromsoe <cbs@cts.ucla.edu>
Subject: WARNING: at net/core/dev.c:1505 skb_gso_segment+0x6e/0x156()
Date: Thu, 26 Feb 2009 23:16:16 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0902262309380.4261@potato.cts.ucla.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out-66.smtp.ucla.edu ([169.232.46.167]:55061 "EHLO
	out-66.smtp.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753051AbZB0HXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 02:23:06 -0500
Received: from potato.cts.ucla.edu (potato.cts.ucla.edu [128.97.128.80])
	by smtp-13.smtp.ucla.edu (8.14.3/8.14.3) with ESMTP id n1R7GHpg004538
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 23:16:17 -0800
Received: from potato.cts.ucla.edu (localhost [127.0.0.1])
	by potato.cts.ucla.edu (8.13.8/8.13.8/Debian-3) with ESMTP id n1R7GHjY004791
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 23:16:17 -0800
Received: from localhost (cbs@localhost)
	by potato.cts.ucla.edu (8.13.8/8.13.8/Submit) with ESMTP id n1R7GH2K004788
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 23:16:17 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm seeing these show up pretty regularly on several Dell 1750s running 
2.6.27.19, with both tg3 ports bonded together in an active-backup 
configuration.

-Chris

------------[ cut here ]------------
WARNING: at net/core/dev.c:1505 skb_gso_segment+0x6e/0x156()
Modules linked in: dm_snapshot dm_mirror dm_log dm_mod ipmi_devintf ipmi_si ipmi_msghandler tg3 bonding
Pid: 1635, comm: apache2 Tainted: G        W 2.6.27.19 #4
  [<c011ebf6>] warn_on_slowpath+0x41/0x65
  [<c035f1a1>] ? _read_unlock_bh+0xe/0x10
  [<c01307c2>] ? notifier_call_chain+0x2b/0x4a
  [<c01307f2>] ? __atomic_notifier_call_chain+0x11/0x13
  [<c0130800>] ? atomic_notifier_call_chain+0xc/0xe
  [<c02de148>] ? nf_ct_deliver_cached_events+0x67/0x6b
  [<c02c1754>] skb_gso_segment+0x6e/0x156
  [<c02c1a06>] dev_hard_start_xmit+0x1ca/0x25a
  [<c02c3cf8>] dev_queue_xmit+0x376/0x436
  [<c0329267>] ip6_output_finish+0x79/0xd1
  [<c0329731>] ip6_output2+0x1c3/0x1cb
  [<c032a441>] ip6_output+0xa76/0xa91
  [<c03290e4>] ? dst_output+0x0/0xb
  [<c02d71f6>] ? nf_hook_slow+0x38/0x8e
  [<c03290e4>] ? dst_output+0x0/0xb
  [<c032bac9>] ip6_xmit+0x2ce/0x395
  [<c0347f00>] inet6_csk_xmit+0x1b6/0x1cb
  [<c02fc356>] tcp_transmit_skb+0x556/0x589
  [<c02fd9c3>] __tcp_push_pending_frames+0x623/0x6c2
  [<c01cdcc2>] ? copy_from_user+0x2c/0x4f
  [<c02f445f>] tcp_sendmsg+0x7e1/0x8e4
  [<c02b7965>] sock_aio_write+0xc3/0xd0
  [<c015875d>] do_sync_readv_writev+0xa1/0xdf
  [<c012d871>] ? autoremove_wake_function+0x0/0x33
  [<c01cdcc2>] ? copy_from_user+0x2c/0x4f
  [<c0158622>] ? rw_copy_check_uvector+0x58/0xbf
  [<c0158d51>] do_readv_writev+0x85/0x140
  [<c02b78a2>] ? sock_aio_write+0x0/0xd0
  [<c0121a23>] ? do_setitimer+0x297/0x2f6
  [<c016abbf>] ? mntput_no_expire+0x18/0xc9
  [<c0158e45>] vfs_writev+0x39/0x49
  [<c01591dd>] sys_writev+0x3b/0x60
  [<c0102b52>] syscall_call+0x7/0xb
  [<c0350000>] ? ipip6_tunnel_xmit+0x381/0x4d7
  =======================
---[ end trace b985ccce15b7cbae ]---

