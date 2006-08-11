From: Johannes Berg <johannes@sipsolutions.net>
Subject: lockdep rt2500usb report
Date: Fri, 11 Aug 2006 10:34:24 +0200
Message-ID: <44DC4110.6080300@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:14994 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750843AbWHKIea
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 04:34:30 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>, netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is running wireless-dev from yesterday. All I did was plug in a 
rt2500usb device into a usb port on a freshly booted system. I have a 
feeling that this is could be one of the problems reported earlier with 
the d80211 stack, but I haven't mastered the art of picking through 
these traces yet... What's swapper doing in there?

[ 1806.889513] usb 5-2: new high speed USB device using ehci_hcd and 
address 2
[ 1807.164838] usb 5-2: configuration #1 chosen from 1 choice
[ 1807.252880] Loading module: rt2500usb - CVS (N/A) by 
http://rt2x00.serialmonkey.com.
[ 1807.338966] wmaster0: Selected rate control algorithm 'simple'
[ 1807.364971] usbcore: registered new driver rt2500usb
[ 1807.658580]
[ 1807.658582] =======================================================
[ 1807.658586] [ INFO: possible circular locking dependency detected ]
[ 1807.658588] -------------------------------------------------------
[ 1807.658591] swapper/0 is trying to acquire lock:
[ 1807.658593]  (&dev->queue_lock){-+..}, at: [<c0297518>] 
dev_queue_xmit+0x52/0 x24f
[ 1807.658603]
[ 1807.658604] but task is already holding lock:
[ 1807.658606]  (&dev->_xmit_lock){-+..}, at: [<c02976b4>] 
dev_queue_xmit+0x1ee/ 0x24f
[ 1807.658611]
[ 1807.658612] which lock already depends on the new lock.
[ 1807.658613]
[ 1807.658615]
[ 1807.658616] the existing dependency chain (in reverse order) is:
[ 1807.658618]
[ 1807.658619] -> #1 (&dev->_xmit_lock){-+..}:
[ 1807.658622]        [<c01322b7>] lock_acquire+0x5c/0x79
[ 1807.658631]        [<c02f5560>] _spin_lock_bh+0x3b/0x48
[ 1807.658639]        [<c02a3231>] dev_activate+0x5e/0x10f
[ 1807.658646]        [<c0295c89>] dev_open+0x5c/0x73
[ 1807.658652]        [<c029538f>] dev_change_flags+0x51/0x107
[ 1807.658659]        [<c029e60a>] do_setlink+0x182/0x378
[ 1807.658665]        [<c029dac2>] rtnetlink_rcv_msg+0x163/0x214
[ 1807.658671]        [<c02a5b9e>] netlink_run_queue+0x83/0x114
[ 1807.658678]        [<c029d833>] rtnetlink_rcv+0x2c/0x49
[ 1807.658684]        [<c02a5c44>] netlink_data_ready+0x15/0x59
[ 1807.658691]        [<c02a3893>] netlink_sendskb+0x1f/0x36
[ 1807.658697]        [<c02a5673>] netlink_unicast+0x190/0x1f2
[ 1807.658703]        [<c02a588f>] netlink_sendmsg+0x1ba/0x29d
[ 1807.658709]        [<c028cb46>] sock_sendmsg+0xcf/0xf3
[ 1807.658717]        [<c028cc60>] sys_sendmsg+0xf6/0x1fb
[ 1807.658723]        [<c028d4af>] sys_socketcall+0x232/0x253
[ 1807.658729]        [<c0102ead>] sysenter_past_esp+0x56/0x8d
[ 1807.658737]
[ 1807.658737] -> #0 (&dev->queue_lock){-+..}:
[ 1807.658740]        [<c01322b7>] lock_acquire+0x5c/0x79
[ 1807.658748]        [<c02f5763>] _spin_lock+0x36/0x43
[ 1807.658754]        [<c0297518>] dev_queue_xmit+0x52/0x24f
[ 1807.658760]        [<e2cb2aff>] 
ieee80211_subif_start_xmit+0x299/0x49f [80211 ]
[ 1807.658777]        [<c02973d9>] dev_hard_start_xmit+0x15f/0x24c
[ 1807.658783]        [<c02976cd>] dev_queue_xmit+0x207/0x24f
[ 1807.658789]        [<e351b8a4>] mld_sendpack+0x228/0x29f [ipv6]
[ 1807.658812]        [<e351bf49>] mld_ifc_timer_expire+0x217/0x260 [ipv6]
[ 1807.658829]        [<c0121a6d>] run_timer_softirq+0xbf/0x1ae
[ 1807.658836]        [<c011e30c>] __do_softirq+0x50/0xc1
[ 1807.658844]        [<c011e3c6>] do_softirq+0x49/0x4b
[ 1807.658849]        [<c011e50f>] irq_exit+0x42/0x44
[ 1807.658855]        [<c01055d4>] do_IRQ+0x3c/0x78
[ 1807.658861]        [<c01039cd>] common_interrupt+0x25/0x2c
[ 1807.658867]        [<c0101c27>] cpu_idle+0x41/0x69
[ 1807.658873]        [<c0100295>] rest_init+0x39/0x3b
[ 1807.658878]        [<c03ee718>] start_kernel+0x2a6/0x31e
[ 1807.658885]        [<c0100199>] 0xc0100199
[ 1807.658894]
[ 1807.658894] other info that might help us debug this:
[ 1807.658895]
[ 1807.658898] 1 lock held by swapper/0:
[ 1807.658899]  #0:  (&dev->_xmit_lock){-+..}, at: [<c02976b4>] 
dev_queue_xmit+0 x1ee/0x24f
[ 1807.658905]
[ 1807.658906] stack backtrace:
[ 1807.658908]  [<c01053a0>] show_trace+0x12/0x14
[ 1807.658911]  [<c01053bb>] dump_stack+0x19/0x1e
[ 1807.658914]  [<c01300f4>] print_circular_bug_tail+0x5d/0x66
[ 1807.658918]  [<c0131d9c>] __lock_acquire+0xb89/0xd8a
[ 1807.658921]  [<c01322b7>] lock_acquire+0x5c/0x79
[ 1807.658925]  [<c02f5763>] _spin_lock+0x36/0x43
[ 1807.658928]  [<c0297518>] dev_queue_xmit+0x52/0x24f
[ 1807.658931]  [<e2cb2aff>] ieee80211_subif_start_xmit+0x299/0x49f [80211]
[ 1807.658942]  [<c02973d9>] dev_hard_start_xmit+0x15f/0x24c
[ 1807.658946]  [<c02976cd>] dev_queue_xmit+0x207/0x24f
[ 1807.658949]  [<e351b8a4>] mld_sendpack+0x228/0x29f [ipv6]
[ 1807.658964]  [<e351bf49>] mld_ifc_timer_expire+0x217/0x260 [ipv6]
[ 1807.658979]  [<c0121a6d>] run_timer_softirq+0xbf/0x1ae
[ 1807.658982]  [<c011e30c>] __do_softirq+0x50/0xc1
[ 1807.658986]  [<c011e3c6>] do_softirq+0x49/0x4b
[ 1807.658989]  [<c011e50f>] irq_exit+0x42/0x44
[ 1807.658992]  [<c01055d4>] do_IRQ+0x3c/0x78
[ 1807.658995]  [<c01039cd>] common_interrupt+0x25/0x2c
[ 1807.658998]  [<c0101c27>] cpu_idle+0x41/0x69
[ 1807.659001]  [<c0100295>] rest_init+0x39/0x3b
[ 1807.659004]  [<c03ee718>] start_kernel+0x2a6/0x31e
[ 1807.659007]  [<c0100199>] 0xc0100199

