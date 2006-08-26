From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: lockdep rt2500usb report
Date: Sat, 26 Aug 2006 11:26:08 +0200
Message-ID: <200608261126.08246.IvDoorn@gmail.com>
References: <44DC4110.6080300@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:24503 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1750805AbWHZJ0Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Aug 2006 05:26:16 -0400
Received: by nf-out-0910.google.com with SMTP id o25so950912nfa
        for <netdev@vger.kernel.org>; Sat, 26 Aug 2006 02:26:14 -0700 (PDT)
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <44DC4110.6080300@sipsolutions.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> This is running wireless-dev from yesterday. All I did was plug in a 
> rt2500usb device into a usb port on a freshly booted system. I have a 
> feeling that this is could be one of the problems reported earlier with 
> the d80211 stack, but I haven't mastered the art of picking through 
> these traces yet... What's swapper doing in there?

Just received a similar bug from another user that has been using rt61pci.
My guess is still a bug in d80211, but I have no idea on how to debug this one.

Jiri, do you have any ideas? 

Aug 26 00:27:57 Arjuna kernel: [ 1219.846213] rt61pci->rt61pci_config_channel: Info - Switching channel. RF1: 0x00002ccc, RF2: 0x00004796, RF3: 0x0006b655, RF4: 0x000ffa0b.
Aug 26 00:27:57 Arjuna kernel: [ 1219.849434] rt61pci->rt61pci_config_channel: Info - Switching channel. RF1: 0x00002ccc, RF2: 0x00004786, RF3: 0x0006b655, RF4: 0x000ffa0b.
Aug 26 00:27:57 Arjuna kernel: [ 1219.851772] rt61pci->rt61pci_init_channel_time: Notice - Channel change time has been set to 3000.
Aug 26 00:27:57 Arjuna kernel: [ 1219.858982] rt61pci->rt61pci_conf_tx: Notice - Ignoring configuration for queue 5.
Aug 26 00:27:57 Arjuna kernel: [ 1219.879794] 
Aug 26 00:27:57 Arjuna kernel: [ 1219.879797] =======================================================
Aug 26 00:27:57 Arjuna kernel: [ 1219.879802] [ INFO: possible circular locking dependency detected ]
Aug 26 00:27:57 Arjuna kernel: [ 1219.879805] -------------------------------------------------------
Aug 26 00:27:57 Arjuna kernel: [ 1219.879807] ifup-eth/4014 is trying to acquire lock:
Aug 26 00:27:57 Arjuna kernel: [ 1219.879810]  (&dev->queue_lock#2){-+..}, at: [<ffffffff8119c3e3>] dev_queue_xmit+0x10c/0x251
Aug 26 00:27:57 Arjuna kernel: [ 1219.879820] 
Aug 26 00:27:57 Arjuna kernel: [ 1219.879821] but task is already holding lock:
Aug 26 00:27:57 Arjuna kernel: [ 1219.879823]  (&dev->_xmit_lock){-+..}, at: [<ffffffff8119c451>] dev_queue_xmit+0x17a/0x251
Aug 26 00:27:57 Arjuna kernel: [ 1219.879829] 
Aug 26 00:27:57 Arjuna kernel: [ 1219.879830] which lock already depends on the new lock.
Aug 26 00:27:57 Arjuna kernel: [ 1219.879831] 
Aug 26 00:27:57 Arjuna kernel: [ 1219.879833] 
Aug 26 00:27:57 Arjuna kernel: [ 1219.879834] the existing dependency chain (in reverse order) is:
Aug 26 00:27:57 Arjuna kernel: [ 1219.879836] 
Aug 26 00:27:57 Arjuna kernel: [ 1219.879837] -> #1 (&dev->_xmit_lock){-+..}:
Aug 26 00:27:57 Arjuna kernel: [ 1219.879840]        [<ffffffff8103fb8c>] lock_acquire+0x7a/0xa1
Aug 26 00:27:57 Arjuna kernel: [ 1219.879848]        [<ffffffff811f7053>] _spin_lock_bh+0x29/0x36
Aug 26 00:27:57 Arjuna kernel: [ 1219.879855]        [<ffffffff811ab935>] dev_activate+0x108/0x142
Aug 26 00:27:57 Arjuna kernel: [ 1219.879862]        [<ffffffff8119badb>] dev_open+0x59/0x77
Aug 26 00:27:57 Arjuna kernel: [ 1219.879867]        [<ffffffff8119986c>] dev_change_flags+0x5c/0x122
Aug 26 00:27:57 Arjuna kernel: [ 1219.879873]        [<ffffffff811ddc34>] devinet_ioctl+0x259/0x5f1
Aug 26 00:27:57 Arjuna kernel: [ 1219.879881]        [<ffffffff811de287>] inet_ioctl+0x70/0x8f
Aug 26 00:27:57 Arjuna kernel: [ 1219.879887]        [<ffffffff8118fd6c>] sock_ioctl+0x1ea/0x20c
Aug 26 00:27:57 Arjuna kernel: [ 1219.879893]        [<ffffffff8108d6d6>] do_ioctl+0x1a/0x50
Aug 26 00:27:57 Arjuna kernel: [ 1219.879900]        [<ffffffff8108d939>] vfs_ioctl+0x22d/0x240
Aug 26 00:27:57 Arjuna kernel: [ 1219.879905]        [<ffffffff8108d9aa>] sys_ioctl+0x5e/0x84
Aug 26 00:27:57 Arjuna kernel: [ 1219.879910]        [<ffffffff81009641>] system_call+0x7d/0x83
Aug 26 00:27:57 Arjuna kernel: [ 1219.879917] 
Aug 26 00:27:57 Arjuna kernel: [ 1219.879918] -> #0 (&dev->queue_lock#2){-+..}:
Aug 26 00:27:57 Arjuna kernel: [ 1219.879921]        [<ffffffff8103fb8c>] lock_acquire+0x7a/0xa1
Aug 26 00:27:57 Arjuna kernel: [ 1219.879927]        [<ffffffff811f701d>] _spin_lock+0x24/0x31
Aug 26 00:27:57 Arjuna kernel: [ 1219.879933]        [<ffffffff8119c3e2>] dev_queue_xmit+0x10b/0x251
Aug 26 00:27:57 Arjuna kernel: [ 1219.879938]        [<ffffffff8816771b>] ieee80211_subif_start_xmit+0x4a3/0x4c2 [80211]
Aug 26 00:27:57 Arjuna kernel: [ 1219.879975]        [<ffffffff8119a43f>] dev_hard_start_xmit+0x1ad/0x223
Aug 26 00:27:57 Arjuna kernel: [ 1219.879981]        [<ffffffff8119c46c>] dev_queue_xmit+0x195/0x251
Aug 26 00:27:57 Arjuna kernel: [ 1219.879987]        [<ffffffff8840c965>] mld_sendpack+0x1a2/0x27c [ipv6]
Aug 26 00:27:57 Arjuna kernel: [ 1219.880018]        [<ffffffff8840d711>] mld_ifc_timer_expire+0x1e6/0x21f [ipv6]
Aug 26 00:27:57 Arjuna kernel: [ 1219.880041]        [<ffffffff8102fa1c>] run_timer_softirq+0x13a/0x1bb
Aug 26 00:27:57 Arjuna kernel: [ 1219.880049]        [<ffffffff8102c75e>] __do_softirq+0x60/0xcc
Aug 26 00:27:57 Arjuna kernel: [ 1219.880055]        [<ffffffff8100a48b>] call_softirq+0x1b/0x28
Aug 26 00:27:57 Arjuna kernel: [ 1219.880061]        [<ffffffff8100b8b1>] do_softirq+0x38/0x9f
Aug 26 00:27:57 Arjuna kernel: [ 1219.880066]        [<ffffffff8102c66a>] irq_exit+0x56/0x59
Aug 26 00:27:57 Arjuna kernel: [ 1219.880072]        [<ffffffff8100ba14>] do_IRQ+0xfc/0x108
Aug 26 00:27:57 Arjuna kernel: [ 1219.880077]        [<ffffffff81009b79>] common_interrupt+0x65/0x66
Aug 26 00:27:57 Arjuna kernel: [ 1219.880083] 
Aug 26 00:27:57 Arjuna kernel: [ 1219.880084] other info that might help us debug this:
Aug 26 00:27:57 Arjuna kernel: [ 1219.880086] 
Aug 26 00:27:57 Arjuna kernel: [ 1219.880088] 3 locks held by ifup-eth/4014:
Aug 26 00:27:57 Arjuna kernel: [ 1219.880090]  #0:  (dcache_lock){--..}, at: [<ffffffff810ea6b1>] _atomic_dec_and_lock+0x15/0x34
Aug 26 00:27:57 Arjuna kernel: [ 1219.880098]  #1:  (&dentry->d_lock){--..}, at: [<ffffffff81092198>] dput+0x4d/0x18e
Aug 26 00:27:57 Arjuna kernel: [ 1219.880104]  #2:  (&dev->_xmit_lock){-+..}, at: [<ffffffff8119c451>] dev_queue_xmit+0x17a/0x251
Aug 26 00:27:57 Arjuna kernel: [ 1219.880110] 
Aug 26 00:27:57 Arjuna kernel: [ 1219.880110] stack backtrace:
Aug 26 00:27:57 Arjuna kernel: [ 1219.880112] 
Aug 26 00:27:57 Arjuna kernel: [ 1219.880113] Call Trace:
Aug 26 00:27:57 Arjuna kernel: [ 1219.880214]  [<ffffffff8100a7a4>] show_trace+0xa0/0x2d6
Aug 26 00:27:57 Arjuna kernel: [ 1219.880227]  [<ffffffff8100a9ef>] dump_stack+0x15/0x17
Aug 26 00:27:57 Arjuna kernel: [ 1219.880239]  [<ffffffff8103e310>] print_circular_bug_tail+0x6c/0x77
Aug 26 00:27:57 Arjuna kernel: [ 1219.880316]  [<ffffffff8103f943>] __lock_acquire+0x866/0xa35
Aug 26 00:27:57 Arjuna kernel: [ 1219.880393]  [<ffffffff8103fb8d>] lock_acquire+0x7b/0xa1
Aug 26 00:27:57 Arjuna kernel: [ 1219.880471]  [<ffffffff811f701e>] _spin_lock+0x25/0x31
Aug 26 00:27:57 Arjuna kernel: [ 1219.880552]  [<ffffffff8119c3e3>] dev_queue_xmit+0x10c/0x251
Aug 26 00:27:57 Arjuna kernel: [ 1219.880977]  [<ffffffff8816771c>] :80211:ieee80211_subif_start_xmit+0x4a4/0x4c2
Aug 26 00:27:57 Arjuna kernel: [ 1219.880989]  [<ffffffff8119a440>] dev_hard_start_xmit+0x1ae/0x223
Aug 26 00:27:57 Arjuna kernel: [ 1219.881382]  [<ffffffff8119c46d>] dev_queue_xmit+0x196/0x251
Aug 26 00:27:57 Arjuna kernel: [ 1219.881794]  [<ffffffff8840c966>] :ipv6:mld_sendpack+0x1a3/0x27c
Aug 26 00:27:57 Arjuna kernel: [ 1219.881838]  [<ffffffff8840d712>] :ipv6:mld_ifc_timer_expire+0x1e7/0x21f
Aug 26 00:27:57 Arjuna kernel: [ 1219.881860]  [<ffffffff8102fa1d>] run_timer_softirq+0x13b/0x1bb
Aug 26 00:27:57 Arjuna kernel: [ 1219.881921]  [<ffffffff8102c75f>] __do_softirq+0x61/0xcc
Aug 26 00:27:57 Arjuna kernel: [ 1219.881974]  [<ffffffff8100a48c>] call_softirq+0x1c/0x28
Aug 26 00:27:57 Arjuna kernel: [ 1219.881985] DWARF2 unwinder stuck at call_softirq+0x1c/0x28
Aug 26 00:27:57 Arjuna kernel: [ 1219.881987] Leftover inexact backtrace:
Aug 26 00:27:58 Arjuna kernel: [ 1219.881989]  <IRQ> [<ffffffff8100b8b2>] do_softirq+0x39/0x9f
Aug 26 00:27:58 Arjuna kernel: [ 1219.882007]  [<ffffffff8102c66b>] irq_exit+0x57/0x59
Aug 26 00:27:58 Arjuna kernel: [ 1219.882011]  [<ffffffff8100ba15>] do_IRQ+0xfd/0x108
Aug 26 00:27:58 Arjuna kernel: [ 1219.882016]  [<ffffffff81092198>] dput+0x4d/0x18e
Aug 26 00:27:58 Arjuna kernel: [ 1219.882020]  [<ffffffff81009b7a>] ret_from_intr+0x0/0xf
Aug 26 00:27:58 Arjuna kernel: [ 1219.882022]  <EOI> [<ffffffff8103fba2>] lock_acquire+0x90/0xa1
Aug 26 00:27:58 Arjuna kernel: [ 1219.882040]  [<ffffffff81092198>] dput+0x4d/0x18e
Aug 26 00:27:58 Arjuna kernel: [ 1219.882051]  [<ffffffff811f701e>] _spin_lock+0x25/0x31
Aug 26 00:27:58 Arjuna kernel: [ 1219.882056]  [<ffffffff81092198>] dput+0x4d/0x18e
Aug 26 00:27:58 Arjuna kernel: [ 1219.882062]  [<ffffffff8108aee5>] __link_path_walk+0xda2/0xf67
Aug 26 00:27:58 Arjuna kernel: [ 1219.882075]  [<ffffffff8108b112>] link_path_walk+0x68/0xfd
Aug 26 00:27:58 Arjuna kernel: [ 1219.882087]  [<ffffffff8107be1a>] vfs_read+0x13d/0x172
Aug 26 00:27:58 Arjuna kernel: [ 1219.882099]  [<ffffffff8108b595>] do_path_lookup+0x275/0x2f2
Aug 26 00:27:58 Arjuna kernel: [ 1219.882109]  [<ffffffff8108c102>] __path_lookup_intent_open+0x5c/0x9f
Aug 26 00:27:58 Arjuna kernel: [ 1219.882117]  [<ffffffff810ab1dc>] load_elf_binary+0x0/0x1a66
Aug 26 00:27:58 Arjuna kernel: [ 1219.882122]  [<ffffffff8108c1b2>] path_lookup_open+0xc/0xe
Aug 26 00:27:58 Arjuna kernel: [ 1219.882127]  [<ffffffff810852f3>] open_exec+0x32/0xe9
Aug 26 00:27:58 Arjuna kernel: [ 1219.882138]  [<ffffffff8107be1a>] vfs_read+0x13d/0x172
Aug 26 00:27:58 Arjuna kernel: [ 1219.882145]  [<ffffffff810851aa>] kernel_read+0x43/0x5a
Aug 26 00:27:58 Arjuna kernel: [ 1219.882152]  [<ffffffff810ab46d>] load_elf_binary+0x291/0x1a66
Aug 26 00:27:58 Arjuna kernel: [ 1219.882163]  [<ffffffff8835f989>] :binfmt_misc:load_misc_binary+0x360/0x375
Aug 26 00:27:58 Arjuna kernel: [ 1219.882170]  [<ffffffff8105eff1>] __alloc_pages+0x74/0x2ba
Aug 26 00:27:58 Arjuna kernel: [ 1219.882176]  [<ffffffff81084fe6>] search_binary_handler+0x149/0x280
Aug 26 00:27:58 Arjuna kernel: [ 1219.882182]  [<ffffffff81084f4d>] search_binary_handler+0xb0/0x280
Aug 26 00:27:58 Arjuna kernel: [ 1219.882191]  [<ffffffff810ab1dc>] load_elf_binary+0x0/0x1a66
Aug 26 00:27:58 Arjuna kernel: [ 1219.882197]  [<ffffffff810ab1dc>] load_elf_binary+0x0/0x1a66
Aug 26 00:27:58 Arjuna kernel: [ 1219.882202]  [<ffffffff81084f57>] search_binary_handler+0xba/0x280
Aug 26 00:27:58 Arjuna kernel: [ 1219.882211]  [<ffffffff81086b76>] do_execve+0x187/0x23d
Aug 26 00:27:58 Arjuna kernel: [ 1219.882219]  [<ffffffff81008377>] sys_execve+0x36/0x8b
Aug 26 00:27:58 Arjuna kernel: [ 1219.882226]  [<ffffffff81009a33>] stub_execve+0x67/0xb0
Aug 26 00:27:58 Arjuna kernel: [ 1219.882242] 
Aug 26 00:29:27 Arjuna kernel: [ 1309.371392] rt61pci->rt61pci_config_channel: Info - Switching channel. RF1: 0x00002ccc, RF2: 0x00004796, RF3: 0x0006b655, RF4: 0x000ffa0b.
Aug 26 00:29:27 Arjuna kernel: [ 1309.376699] wlan0: cannot create symlink to default key
Aug 26 00:29:27 Arjuna kernel: [ 1309.378033] rt61pci->rt61pci_conf_tx: Notice - Ignoring configuration for queue 5.
Aug 26 00:40:25 Arjuna kernel: 0060/serio1/input0, Type: 2, Code: 0, Value: 8

> [ 1806.889513] usb 5-2: new high speed USB device using ehci_hcd and 
> address 2
> [ 1807.164838] usb 5-2: configuration #1 chosen from 1 choice
> [ 1807.252880] Loading module: rt2500usb - CVS (N/A) by 
> http://rt2x00.serialmonkey.com.
> [ 1807.338966] wmaster0: Selected rate control algorithm 'simple'
> [ 1807.364971] usbcore: registered new driver rt2500usb
> [ 1807.658580]
> [ 1807.658582] =======================================================
> [ 1807.658586] [ INFO: possible circular locking dependency detected ]
> [ 1807.658588] -------------------------------------------------------
> [ 1807.658591] swapper/0 is trying to acquire lock:
> [ 1807.658593]  (&dev->queue_lock){-+..}, at: [<c0297518>] 
> dev_queue_xmit+0x52/0 x24f
> [ 1807.658603]
> [ 1807.658604] but task is already holding lock:
> [ 1807.658606]  (&dev->_xmit_lock){-+..}, at: [<c02976b4>] 
> dev_queue_xmit+0x1ee/ 0x24f
> [ 1807.658611]
> [ 1807.658612] which lock already depends on the new lock.
> [ 1807.658613]
> [ 1807.658615]
> [ 1807.658616] the existing dependency chain (in reverse order) is:
> [ 1807.658618]
> [ 1807.658619] -> #1 (&dev->_xmit_lock){-+..}:
> [ 1807.658622]        [<c01322b7>] lock_acquire+0x5c/0x79
> [ 1807.658631]        [<c02f5560>] _spin_lock_bh+0x3b/0x48
> [ 1807.658639]        [<c02a3231>] dev_activate+0x5e/0x10f
> [ 1807.658646]        [<c0295c89>] dev_open+0x5c/0x73
> [ 1807.658652]        [<c029538f>] dev_change_flags+0x51/0x107
> [ 1807.658659]        [<c029e60a>] do_setlink+0x182/0x378
> [ 1807.658665]        [<c029dac2>] rtnetlink_rcv_msg+0x163/0x214
> [ 1807.658671]        [<c02a5b9e>] netlink_run_queue+0x83/0x114
> [ 1807.658678]        [<c029d833>] rtnetlink_rcv+0x2c/0x49
> [ 1807.658684]        [<c02a5c44>] netlink_data_ready+0x15/0x59
> [ 1807.658691]        [<c02a3893>] netlink_sendskb+0x1f/0x36
> [ 1807.658697]        [<c02a5673>] netlink_unicast+0x190/0x1f2
> [ 1807.658703]        [<c02a588f>] netlink_sendmsg+0x1ba/0x29d
> [ 1807.658709]        [<c028cb46>] sock_sendmsg+0xcf/0xf3
> [ 1807.658717]        [<c028cc60>] sys_sendmsg+0xf6/0x1fb
> [ 1807.658723]        [<c028d4af>] sys_socketcall+0x232/0x253
> [ 1807.658729]        [<c0102ead>] sysenter_past_esp+0x56/0x8d
> [ 1807.658737]
> [ 1807.658737] -> #0 (&dev->queue_lock){-+..}:
> [ 1807.658740]        [<c01322b7>] lock_acquire+0x5c/0x79
> [ 1807.658748]        [<c02f5763>] _spin_lock+0x36/0x43
> [ 1807.658754]        [<c0297518>] dev_queue_xmit+0x52/0x24f
> [ 1807.658760]        [<e2cb2aff>] 
> ieee80211_subif_start_xmit+0x299/0x49f [80211 ]
> [ 1807.658777]        [<c02973d9>] dev_hard_start_xmit+0x15f/0x24c
> [ 1807.658783]        [<c02976cd>] dev_queue_xmit+0x207/0x24f
> [ 1807.658789]        [<e351b8a4>] mld_sendpack+0x228/0x29f [ipv6]
> [ 1807.658812]        [<e351bf49>] mld_ifc_timer_expire+0x217/0x260 [ipv6]
> [ 1807.658829]        [<c0121a6d>] run_timer_softirq+0xbf/0x1ae
> [ 1807.658836]        [<c011e30c>] __do_softirq+0x50/0xc1
> [ 1807.658844]        [<c011e3c6>] do_softirq+0x49/0x4b
> [ 1807.658849]        [<c011e50f>] irq_exit+0x42/0x44
> [ 1807.658855]        [<c01055d4>] do_IRQ+0x3c/0x78
> [ 1807.658861]        [<c01039cd>] common_interrupt+0x25/0x2c
> [ 1807.658867]        [<c0101c27>] cpu_idle+0x41/0x69
> [ 1807.658873]        [<c0100295>] rest_init+0x39/0x3b
> [ 1807.658878]        [<c03ee718>] start_kernel+0x2a6/0x31e
> [ 1807.658885]        [<c0100199>] 0xc0100199
> [ 1807.658894]
> [ 1807.658894] other info that might help us debug this:
> [ 1807.658895]
> [ 1807.658898] 1 lock held by swapper/0:
> [ 1807.658899]  #0:  (&dev->_xmit_lock){-+..}, at: [<c02976b4>] 
> dev_queue_xmit+0 x1ee/0x24f
> [ 1807.658905]
> [ 1807.658906] stack backtrace:
> [ 1807.658908]  [<c01053a0>] show_trace+0x12/0x14
> [ 1807.658911]  [<c01053bb>] dump_stack+0x19/0x1e
> [ 1807.658914]  [<c01300f4>] print_circular_bug_tail+0x5d/0x66
> [ 1807.658918]  [<c0131d9c>] __lock_acquire+0xb89/0xd8a
> [ 1807.658921]  [<c01322b7>] lock_acquire+0x5c/0x79
> [ 1807.658925]  [<c02f5763>] _spin_lock+0x36/0x43
> [ 1807.658928]  [<c0297518>] dev_queue_xmit+0x52/0x24f
> [ 1807.658931]  [<e2cb2aff>] ieee80211_subif_start_xmit+0x299/0x49f [80211]
> [ 1807.658942]  [<c02973d9>] dev_hard_start_xmit+0x15f/0x24c
> [ 1807.658946]  [<c02976cd>] dev_queue_xmit+0x207/0x24f
> [ 1807.658949]  [<e351b8a4>] mld_sendpack+0x228/0x29f [ipv6]
> [ 1807.658964]  [<e351bf49>] mld_ifc_timer_expire+0x217/0x260 [ipv6]
> [ 1807.658979]  [<c0121a6d>] run_timer_softirq+0xbf/0x1ae
> [ 1807.658982]  [<c011e30c>] __do_softirq+0x50/0xc1
> [ 1807.658986]  [<c011e3c6>] do_softirq+0x49/0x4b
> [ 1807.658989]  [<c011e50f>] irq_exit+0x42/0x44
> [ 1807.658992]  [<c01055d4>] do_IRQ+0x3c/0x78
> [ 1807.658995]  [<c01039cd>] common_interrupt+0x25/0x2c
> [ 1807.658998]  [<c0101c27>] cpu_idle+0x41/0x69
> [ 1807.659001]  [<c0100295>] rest_init+0x39/0x3b
> [ 1807.659004]  [<c03ee718>] start_kernel+0x2a6/0x31e
> [ 1807.659007]  [<c0100199>] 0xc0100199
> 
> 
