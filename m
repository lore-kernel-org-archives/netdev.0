From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Possible circular locking in current wireless-dev.git
Date: Sun, 03 Sep 2006 11:33:04 -0500
Message-ID: <44FB03C0.5080204@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:64734 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751415AbWICQdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Sep 2006 12:33:08 -0400
To: Jiri Benc <jbenc@suse.cz>, jkmaline@cc.hut.fi
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When booting the latest version of Linville's wireless-dev and starting my BCM4306 with WPA-PSK
TKIP, the I get the following INFO printout that indicates a possible circular locking dependency
involving 80211 and wpa_supplicant.

Thanks,

Larry

kernel: =======================================================
kernel: [ INFO: possible circular locking dependency detected ]
kernel: -------------------------------------------------------
kernel: wpa_supplicant/4266 is trying to acquire lock:
kernel:  (&dev->queue_lock){-+..}, at: [<c02c3b76>] dev_queue_xmit+0x56/0x290
kernel:
kernel: but task is already holding lock:
kernel:  (&dev->_xmit_lock){-+..}, at: [<c02c3d46>] dev_queue_xmit+0x226/0x290
kernel:
kernel: which lock already depends on the new lock.
kernel:
kernel:
kernel: the existing dependency chain (in reverse order) is:
kernel:
kernel: -> #1 (&dev->_xmit_lock){-+..}:
kernel:        [<c013363b>] lock_acquire+0x5b/0x80
kernel:        [<c0314880>] _spin_lock_bh+0x40/0x50
kernel:        [<c02cfaac>] dev_activate+0x6c/0x130
kernel:        [<c02c225b>] dev_open+0x6b/0x90
kernel:        [<e79681dd>] ieee80211_open+0x18d/0x360 [80211]
kernel:        [<c02c2233>] dev_open+0x43/0x90
kernel:        [<c02c11c5>] dev_change_flags+0x55/0x130
kernel:        [<c03006af>] devinet_ioctl+0x65f/0x6d0
kernel:        [<c0300a18>] inet_ioctl+0x88/0xb0
kernel:        [<c02b64cb>] sock_ioctl+0xbb/0x260
kernel:        [<c01718db>] do_ioctl+0x2b/0x80
kernel:        [<c0171981>] vfs_ioctl+0x51/0x290
kernel:        [<c0171c01>] sys_ioctl+0x41/0x60
kernel:        [<c0103005>] sysenter_past_esp+0x56/0x8d
kernel:
kernel: -> #0 (&dev->queue_lock){-+..}:
kernel:        [<c013363b>] lock_acquire+0x5b/0x80
kernel:        [<c031482b>] _spin_lock+0x3b/0x50
kernel:        [<c02c3b76>] dev_queue_xmit+0x56/0x290
kernel:        [<e796729f>] ieee80211_subif_start_xmit+0x2df/0x540 [80211]
kernel:        [<c02c3a22>] dev_hard_start_xmit+0x142/0x240
kernel:        [<c02c3d64>] dev_queue_xmit+0x244/0x290
kernel:        [<c03115cc>] packet_sendmsg+0x1fc/0x280
kernel:        [<c02b7b4a>] sock_sendmsg+0xda/0x110
kernel:        [<c02b7eb3>] sys_sendto+0xd3/0x100
kernel:        [<c02b8552>] sys_socketcall+0x192/0x260
kernel:        [<c0103005>] sysenter_past_esp+0x56/0x8d
kernel:
kernel: other info that might help us debug this:
kernel:
kernel: 1 lock held by wpa_supplicant/4266:
kernel:  #0:  (&dev->_xmit_lock){-+..}, at: [<c02c3d46>] dev_queue_xmit+0x226/0x290
kernel:
kernel: stack backtrace:
kernel:  [<c0103b67>] show_trace_log_lvl+0x197/0x1c0
kernel:  [<c0104f7b>] show_trace+0x1b/0x20
kernel:  [<c0104fa6>] dump_stack+0x26/0x30
kernel:  [<c0131361>] print_circular_bug_tail+0x61/0x70
kernel:  [<c0133090>] __lock_acquire+0xae0/0xd60
kernel:  [<c013363b>] lock_acquire+0x5b/0x80
kernel:  [<c031482b>] _spin_lock+0x3b/0x50
kernel:  [<c02c3b76>] dev_queue_xmit+0x56/0x290
kernel:  [<e796729f>] ieee80211_subif_start_xmit+0x2df/0x540 [80211]
kernel:  [<c02c3a22>] dev_hard_start_xmit+0x142/0x240
kernel:  [<c02c3d64>] dev_queue_xmit+0x244/0x290
kernel:  [<c03115cc>] packet_sendmsg+0x1fc/0x280
kernel:  [<c02b7b4a>] sock_sendmsg+0xda/0x110
kernel:  [<c02b7eb3>] sys_sendto+0xd3/0x100
kernel:  [<c02b8552>] sys_socketcall+0x192/0x260
kernel:  [<c0103005>] sysenter_past_esp+0x56/0x8d
kernel:  [<b7fb8410>] 0xb7fb8410
kernel:  [<c0104f7b>] show_trace+0x1b/0x20
kernel:  [<c0104fa6>] dump_stack+0x26/0x30
kernel:  [<c0131361>] print_circular_bug_tail+0x61/0x70
kernel:  [<c0133090>] __lock_acquire+0xae0/0xd60
kernel:  [<c013363b>] lock_acquire+0x5b/0x80
kernel:  [<c031482b>] _spin_lock+0x3b/0x50
kernel:  [<c02c3b76>] dev_queue_xmit+0x56/0x290
kernel:  [<e796729f>] ieee80211_subif_start_xmit+0x2df/0x540 [80211]
kernel:  [<c02c3a22>] dev_hard_start_xmit+0x142/0x240
kernel:  [<c02c3d64>] dev_queue_xmit+0x244/0x290
kernel:  [<c03115cc>] packet_sendmsg+0x1fc/0x280
kernel:  [<c02b7b4a>] sock_sendmsg+0xda/0x110
kernel:  [<c02b7eb3>] sys_sendto+0xd3/0x100
kernel:  [<c02b8552>] sys_socketcall+0x192/0x260
kernel:  [<c0103005>] sysenter_past_esp+0x56/0x8d

-- 
VGER BF report: U 0.503392
