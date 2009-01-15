From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.29-rc1-wl gives WARNING on ich8lan
Date: Wed, 14 Jan 2009 22:25:50 -0800
Message-ID: <20090114222550.80fb1bb2.akpm@linux-foundation.org>
References: <20090114231546.GI1457@gamma.logic.tuwien.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Graham <david.graham@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Norbert Preining <preining@logic.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58528 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753054AbZAOG0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 01:26:12 -0500
In-Reply-To: <20090114231546.GI1457@gamma.logic.tuwien.ac.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jan 2009 00:15:46 +0100 Norbert Preining <preining@logic.at> wrote:

> Hi all,
> 
> (please cc)

(please cc right lists!)

> 2.6.29-rc1-wl (wireless testing) gives me:
> 
> [  367.804080] WARNING: at drivers/net/e1000e/ich8lan.c:412 e1000_acquire_swflag_ich8lan+0x35/0xcc()
> [  367.804085] Hardware name: VGN-Z11VN_B
> [  367.804088] e1000e mutex contention. Owned by pid 3781
> [  367.804092] Modules linked in: binfmt_misc rfcomm l2cap kvm isofs zlib_inflate fuse dm_crypt dm_mod firewire_sbp2 loop arc4 iwlagn iwlcore rfkill joydev firewire_ohci mac80211 firewire_core crc_itu_t cfg80211 btusb sony_laptop tpm_infineon video backlight
> [  367.804143] Pid: 8, comm: events/1 Not tainted 2.6.29-rc1-wl #1
> [  367.804148] Call Trace:
> [  367.804158]  [<ffffffff80236441>] warn_slowpath+0xd8/0x112
> [  367.804169]  [<ffffffff8051152f>] _spin_unlock_irqrestore+0x31/0x3d
> [  367.804178]  [<ffffffff802324f9>] try_to_wake_up+0x168/0x17a
> [  367.804186]  [<ffffffff8023250b>] default_wake_function+0x0/0x9
> [  367.804196]  [<ffffffff80323438>] delay_tsc+0x0/0xc8
> [  367.804204]  [<ffffffff8022c48d>] dequeue_entity+0xf/0x102
> [  367.804211]  [<ffffffff803a12a4>] e1000_acquire_swflag_ich8lan+0x35/0xcc
> [  367.804219]  [<ffffffff803a5c0b>] e1000e_read_phy_reg_bm+0x39/0xbe
> [  367.804227]  [<ffffffff803a5ee7>] e1000e_phy_has_link_generic+0x50/0xcc
> [  367.804234]  [<ffffffff8022c48d>] dequeue_entity+0xf/0x102
> [  367.804242]  [<ffffffff803ad593>] e1000_watchdog_task+0x0/0x6ef
> [  367.804249]  [<ffffffff803a4d25>] e1000e_check_for_copper_link+0x24/0x86
> [  367.804257]  [<ffffffff8023f05e>] lock_timer_base+0x26/0x4b
> [  367.804265]  [<ffffffff803aa186>] e1000_has_link+0x40/0xc1
> [  367.804272]  [<ffffffff803ad5ca>] e1000_watchdog_task+0x37/0x6ef
> [  367.804280]  [<ffffffff803ad593>] e1000_watchdog_task+0x0/0x6ef
> [  367.804289]  [<ffffffff80245058>] run_workqueue+0x87/0x122
> [  367.804296]  [<ffffffff802451cb>] worker_thread+0xd8/0xe7
> [  367.804304]  [<ffffffff802487a8>] autoremove_wake_function+0x0/0x2e
> [  367.804311]  [<ffffffff802450f3>] worker_thread+0x0/0xe7
> [  367.804318]  [<ffffffff802450f3>] worker_thread+0x0/0xe7
> [  367.804324]  [<ffffffff8024848f>] kthread+0x47/0x73
> [  367.804332]  [<ffffffff8020c6aa>] child_rip+0xa/0x20
> [  367.804338]  [<ffffffff80248448>] kthread+0x0/0x73
> [  367.804344]  [<ffffffff8020c6a0>] child_rip+0x0/0x20
> [  367.804349] ---[ end trace 608ec83548aefe5d ]---
> 
> Should I be concerned?
> 

I don't think so.  It looks like it's just some developer debug code:

	if (!mutex_trylock(&nvm_mutex)) {
		WARN(1, KERN_ERR "e1000e mutex contention. Owned by process "
		     "%s (pid %d), required by process %s (pid %d)\n",
		     nvm_owner_name, nvm_owner_pid,
		     current->comm, current->pid);

		mutex_lock(&nvm_mutex);
	}

guys, is this actually indicative of a bug?  An unexpected state?

If not, I'd suggest that this code simply be removed, or downgraded
into a developer-only debug thing.  We don't want the kernel to be
spewing scary things at people.

