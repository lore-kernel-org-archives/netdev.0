From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: Re: 2.6.23-rc2-mm1: rtl8139 inconsistent lock state
Date: Fri, 10 Aug 2007 01:49:14 +0200
Message-ID: <200708100149.14446.m.kozlowski@tuxland.pl>
References: <20070809015106.cd0bfc53.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-664.zgora.dialog.net.pl ([81.168.226.152]:1846 "EHLO
	tuxland.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750792AbXHIXtS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 19:49:18 -0400
In-Reply-To: <20070809015106.cd0bfc53.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

=================================
[ INFO: inconsistent lock state ]
2.6.23-rc2-mm1 #7
---------------------------------
inconsistent {in-hardirq-W} -> {hardirq-on-W} usage.
ifconfig/5492 [HC0[0]:SC0[0]:HE1:SE1] takes:
 (&tp->lock){+...}, at: [<de8706e0>] rtl8139_interrupt+0x27/0x46b [8139too]
{in-hardirq-W} state was registered at:
  [<c0138eeb>] __lock_acquire+0x949/0x11ac
  [<c01397e7>] lock_acquire+0x99/0xb2
  [<c0452ff3>] _spin_lock+0x35/0x42
  [<de8706e0>] rtl8139_interrupt+0x27/0x46b [8139too]
  [<c0147a5d>] handle_IRQ_event+0x28/0x59
  [<c01493ca>] handle_level_irq+0xad/0x10b
  [<c0105a13>] do_IRQ+0x93/0xd0
  [<c010441e>] common_interrupt+0x2e/0x34
  [<c0370d2b>] cpuidle_idle_call+0x74/0x99
  [<c01023e7>] cpu_idle+0x87/0x89
  [<c044fa24>] rest_init+0x60/0x62
  [<c05f8ad5>] start_kernel+0x23a/0x2c5
  [<00000000>] 0x0
  [<ffffffff>] 0xffffffff
irq event stamp: 1777
hardirqs last  enabled at (1777): [<c0169c04>] kfree+0xee/0x105
hardirqs last disabled at (1776): [<c0169b9d>] kfree+0x87/0x105
softirqs last  enabled at (1756): [<c03cb7ab>] dev_deactivate+0x86/0xa5
softirqs last disabled at (1754): [<c045300e>] _spin_lock_bh+0xe/0x47

other info that might help us debug this:
1 lock held by ifconfig/5492:
 #0:  (rtnl_mutex){--..}, at: [<c0451778>] mutex_lock+0x1c/0x1f

stack backtrace:
 [<c0104869>] show_trace_log_lvl+0x1a/0x30
 [<c01053ad>] show_trace+0x12/0x14
 [<c0105515>] dump_stack+0x15/0x17
 [<c0136ed9>] print_usage_bug+0x145/0x14f
 [<c0137ce7>] mark_lock+0x61f/0x70c
 [<c0138ce0>] __lock_acquire+0x73e/0x11ac
 [<c01397e7>] lock_acquire+0x99/0xb2
 [<c0452ff3>] _spin_lock+0x35/0x42
 [<de8706e0>] rtl8139_interrupt+0x27/0x46b [8139too]
 [<c01480fd>] free_irq+0x11b/0x146
 [<de871d59>] rtl8139_close+0x8a/0x14a [8139too]
 [<c03bde63>] dev_close+0x57/0x74
 [<c03bce65>] dev_change_flags+0x8e/0x190
 [<c03fd37c>] devinet_ioctl+0x4af/0x652
 [<c03fdc62>] inet_ioctl+0x56/0x71
 [<c03b1dba>] sock_ioctl+0xa5/0x1d4
 [<c0178b42>] do_ioctl+0x22/0x71
 [<c0178be6>] vfs_ioctl+0x55/0x29e
 [<c0178e62>] sys_ioctl+0x33/0x69
 [<c01041aa>] sysenter_past_esp+0x5f/0x99
 =======================

Regards,

	Mariusz
