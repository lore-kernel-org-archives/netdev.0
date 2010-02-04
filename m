From: Tejun Heo <teheo@suse.de>
Subject: Re: lockdep complaining about btusb during hibernation
Date: Thu, 04 Feb 2010 10:33:02 +0900
Message-ID: <4B6A23CE.1090209@suse.de>
References: <201002031828.53945.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Marcel Holtmann <marcel@holtmann.org>,
	linux-pm@vger.kernel.org, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:55206 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758034Ab0BDB01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2010 20:26:27 -0500
In-Reply-To: <201002031828.53945.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like another sysfs annotation problem.  cc'ing Eric.

On 02/04/2010 02:28 AM, Oliver Neukum wrote:
> Hi,
> 
> I've got lockdep complaining in the latest Linus tree when doing STD.
> 
> 	Regards
> 		Oliver
> 
> Feb  3 17:02:59 vanamonde kernel: =======================================================
> Feb  3 17:02:59 vanamonde kernel: [ INFO: possible circular locking dependency detected ]
> Feb  3 17:02:59 vanamonde kernel: 2.6.33-rc6-0.1-default #50
> Feb  3 17:02:59 vanamonde kernel: -------------------------------------------------------
> Feb  3 17:03:00 vanamonde kernel: bash/2406 is trying to acquire lock:
> Feb  3 17:03:00 vanamonde kernel:  (rtnl_mutex){+.+.+.}, at: [<ffffffff812b74c6>] rtnl_lock+0x12/0x14
> Feb  3 17:03:00 vanamonde kernel: 
> Feb  3 17:03:00 vanamonde kernel: but task is already holding lock:
> Feb  3 17:03:00 vanamonde kernel:  (pm_mutex){+.+.+.}, at: [<ffffffff81077e1c>] hibernate+0x17/0x16d
> Feb  3 17:03:00 vanamonde kernel: 
> Feb  3 17:03:00 vanamonde kernel: which lock already depends on the new lock.
> Feb  3 17:03:00 vanamonde kernel: 
> Feb  3 17:03:00 vanamonde kernel: 
> Feb  3 17:03:00 vanamonde kernel: the existing dependency chain (in reverse order) is:
> Feb  3 17:03:01 vanamonde bluetoothd[1780]: Stopping security manager 0
> Feb  3 17:03:04 vanamonde bluetoothd[1780]: HCI dev 0 down
> Feb  3 17:03:04 vanamonde kernel: 
> Feb  3 17:03:04 vanamonde kernel: -> #2 (pm_mutex){+.+.+.}:
> Feb  3 17:03:04 vanamonde kernel:        [<ffffffff8106ab91>] __lock_acquire+0x135e/0x16eb
> Feb  3 17:03:04 vanamonde kernel:        [<ffffffff8106afea>] lock_acquire+0xcc/0xe9
> Feb  3 17:03:04 vanamonde kernel:        [<ffffffff81331e2a>] mutex_lock_nested+0x54/0x2b5
> Feb  3 17:03:04 vanamonde kernel:        [<ffffffff81077c06>] resume_store+0x61/0xa2
> Feb  3 17:03:04 vanamonde kernel:        [<ffffffff811d3fef>] kobj_attr_store+0x17/0x19
> Feb  3 17:03:04 vanamonde kernel:        [<ffffffff8114332a>] sysfs_write_file+0x103/0x13f
> Feb  3 17:03:04 vanamonde bluetoothd[1780]: Adapter /org/bluez/1775/hci0 has been disabled
> Feb  3 17:03:05 vanamonde bluetoothd[1780]: HCI dev 0 unregistered
> Feb  3 17:03:05 vanamonde bluetoothd[1780]: Unregister path: /org/bluez/1775/hci0
> Feb  3 17:03:05 vanamonde bluetoothd[1780]: HCI dev 0 registered
> Feb  3 17:03:05 vanamonde kernel:        [<ffffffff810ed676>] vfs_write+0xad/0x172
> Feb  3 17:03:05 vanamonde kernel:        [<ffffffff810ed7f4>] sys_write+0x45/0x6c
> Feb  3 17:03:05 vanamonde kernel:        [<ffffffff810029ab>] system_call_fastpath+0x16/0x1b
> Feb  3 17:03:05 vanamonde kernel: 
> Feb  3 17:03:05 vanamonde kernel: -> #1 (s_active){++++.+}:
> Feb  3 17:03:06 vanamonde bluetoothd[1780]: HCI dev 0 up
> Feb  3 17:03:06 vanamonde bluetoothd[1780]: Starting security manager 0
> Feb  3 17:03:06 vanamonde kernel:        [<ffffffff8106ab91>] __lock_acquire+0x135e/0x16eb
> Feb  3 17:03:06 vanamonde kernel:        [<ffffffff8106afea>] lock_acquire+0xcc/0xe9
> Feb  3 17:03:06 vanamonde kernel:        [<ffffffff81143f56>] sysfs_deactivate+0x86/0xc3
> Feb  3 17:03:06 vanamonde kernel:        [<ffffffff81144633>] sysfs_addrm_finish+0x31/0x5a
> Feb  3 17:03:06 vanamonde kernel:        [<ffffffff81142931>] sysfs_hash_and_remove+0x4e/0x65
> Feb  3 17:03:06 vanamonde kernel:        [<ffffffff81145814>] sysfs_remove_group+0x8c/0xc5
> Feb  3 17:03:06 vanamonde kernel:        [<ffffffff81269570>] dpm_sysfs_remove+0x14/0x16
> Feb  3 17:03:06 vanamonde kernel:        [<ffffffff81263d37>] device_del+0x47/0x181
> Feb  3 17:03:06 vanamonde bluetoothd[1780]: Parsing /etc/bluetooth/serial.conf failed: No such file or directory
> Feb  3 17:03:07 vanamonde kernel:        [<ffffffff812ba61c>] netdev_unregister_kobject+0x24/0x28
> Feb  3 17:03:07 vanamonde kernel:        [<ffffffff812ae837>] rollback_registered_many+0x29b/0x300
> Feb  3 17:03:07 vanamonde kernel:        [<ffffffff812ae97d>] unregister_netdevice_queue+0x7f/0xb2
> Feb  3 17:03:07 vanamonde kernel:        [<ffffffff812ae9cc>] unregister_netdev+0x1c/0x23
> Feb  3 17:03:07 vanamonde kernel:        [<ffffffffa04730c4>] usbnet_disconnect+0x87/0xba [usbnet]
> Feb  3 17:03:07 vanamonde kernel:        [<ffffffffa00bb6ac>] usb_unbind_interface+0x69/0xf4 [usbcore]
> Feb  3 17:03:07 vanamonde kernel:        [<ffffffff8126617e>] __device_release_driver+0x76/0xcc
> Feb  3 17:03:07 vanamonde bluetoothd[1780]: Adapter /org/bluez/1775/hci0 has been enabled
> Feb  3 17:03:07 vanamonde kernel:        [<ffffffff812662a2>] device_release_driver+0x1e/0x2b
> Feb  3 17:03:07 vanamonde kernel:        [<ffffffff81265797>] bus_remove_device+0xa8/0xbd
> Feb  3 17:03:07 vanamonde kernel:        [<ffffffff81263e22>] device_del+0x132/0x181
> Feb  3 17:03:07 vanamonde kernel:        [<ffffffffa00b8446>] usb_disable_device+0x101/0x17e [usbcore]
> Feb  3 17:03:07 vanamonde kernel:        [<ffffffffa00b2c24>] usb_disconnect+0xdb/0x150 [usbcore]
> Feb  3 17:03:07 vanamonde kernel:        [<ffffffffa00b434e>] hub_thread+0x6e6/0x1268 [usbcore]
> Feb  3 17:03:07 vanamonde kernel:        [<ffffffff8105837b>] kthread+0x7a/0x82
> Feb  3 17:03:07 vanamonde kernel:        [<ffffffff810037d4>] kernel_thread_helper+0x4/0x10
> Feb  3 17:03:07 vanamonde kernel: 
> Feb  3 17:03:08 vanamonde kernel: -> #0 (rtnl_mutex){+.+.+.}:
> Feb  3 17:03:08 vanamonde kernel:        [<ffffffff8106a841>] __lock_acquire+0x100e/0x16eb
> Feb  3 17:03:08 vanamonde kernel:        [<ffffffff8106afea>] lock_acquire+0xcc/0xe9
> Feb  3 17:03:08 vanamonde kernel:        [<ffffffff81331e2a>] mutex_lock_nested+0x54/0x2b5
> Feb  3 17:03:08 vanamonde kernel:        [<ffffffff812b74c6>] rtnl_lock+0x12/0x14
> Feb  3 17:03:08 vanamonde kernel:        [<ffffffffa020c452>] wiphy_suspend+0x35/0x58 [cfg80211]
> Feb  3 17:03:08 vanamonde kernel:        [<ffffffff81269c34>] legacy_suspend+0x29/0x63
> Feb  3 17:03:08 vanamonde kernel:        [<ffffffff81269faa>] dpm_suspend_start+0x2e5/0x444
> Feb  3 17:03:08 vanamonde kernel:        [<ffffffff81077c8b>] hibernation_snapshot+0x44/0x1be
> Feb  3 17:03:08 vanamonde kernel:        [<ffffffff81077ece>] hibernate+0xc9/0x16d
> Feb  3 17:03:09 vanamonde kernel:        [<ffffffff81076d33>] state_store+0x57/0xce
> Feb  3 17:03:09 vanamonde kernel:        [<ffffffff811d3fef>] kobj_attr_store+0x17/0x19
> Feb  3 17:03:09 vanamonde kernel:        [<ffffffff8114332a>] sysfs_write_file+0x103/0x13f
> Feb  3 17:03:09 vanamonde kernel:        [<ffffffff810ed676>] vfs_write+0xad/0x172
> Feb  3 17:03:09 vanamonde kernel:        [<ffffffff810ed7f4>] sys_write+0x45/0x6c
> Feb  3 17:03:09 vanamonde kernel:        [<ffffffff810029ab>] system_call_fastpath+0x16/0x1b
> Feb  3 17:03:09 vanamonde kernel: 
> Feb  3 17:03:09 vanamonde kernel: other info that might help us debug this:
> Feb  3 17:03:09 vanamonde kernel: 
> Feb  3 17:03:09 vanamonde kernel: 4 locks held by bash/2406:
> Feb  3 17:03:09 vanamonde kernel:  #0:  (&buffer->mutex){+.+.+.}, at: [<ffffffff8114325e>] sysfs_write_file+0x37/0x13f
> Feb  3 17:03:09 vanamonde kernel:  #1:  (s_active){++++.+}, at: [<ffffffff8114489f>] sysfs_get_active_two+0x1f/0x44
> Feb  3 17:03:09 vanamonde kernel:  #2:  (s_active){++++.+}, at: [<ffffffff811448ac>] sysfs_get_active_two+0x2c/0x44
> Feb  3 17:03:09 vanamonde kernel:  #3:  (pm_mutex){+.+.+.}, at: [<ffffffff81077e1c>] hibernate+0x17/0x16d
> Feb  3 17:03:09 vanamonde kernel: 
> Feb  3 17:03:09 vanamonde kernel: stack backtrace:
> Feb  3 17:03:09 vanamonde kernel: Pid: 2406, comm: bash Not tainted 2.6.33-rc6-0.1-default #50
> Feb  3 17:03:09 vanamonde kernel: Call Trace:
> Feb  3 17:03:09 vanamonde kernel:  [<ffffffff813336ef>] ? _raw_spin_unlock_irqrestore+0x33/0x41
> Feb  3 17:03:09 vanamonde kernel:  [<ffffffff810692f5>] print_circular_bug+0xaf/0xbe
> Feb  3 17:03:10 vanamonde kernel:  [<ffffffff8106a841>] __lock_acquire+0x100e/0x16eb
> Feb  3 17:03:10 vanamonde kernel:  [<ffffffff8106afea>] lock_acquire+0xcc/0xe9
> Feb  3 17:03:10 vanamonde kernel:  [<ffffffff812b74c6>] ? rtnl_lock+0x12/0x14
> Feb  3 17:03:10 vanamonde kernel:  [<ffffffffa020c41d>] ? wiphy_suspend+0x0/0x58 [cfg80211]
> Feb  3 17:03:10 vanamonde kernel:  [<ffffffff81331e2a>] mutex_lock_nested+0x54/0x2b5
> Feb  3 17:03:10 vanamonde kernel:  [<ffffffff812b74c6>] ? rtnl_lock+0x12/0x14
> Feb  3 17:03:10 vanamonde kernel:  [<ffffffffa020c41d>] ? wiphy_suspend+0x0/0x58 [cfg80211]
> Feb  3 17:03:10 vanamonde kernel:  [<ffffffff812b74c6>] rtnl_lock+0x12/0x14
> Feb  3 17:03:10 vanamonde kernel:  [<ffffffffa020c452>] wiphy_suspend+0x35/0x58 [cfg80211]
> Feb  3 17:03:10 vanamonde kernel:  [<ffffffff81269c34>] legacy_suspend+0x29/0x63
> Feb  3 17:03:11 vanamonde kernel:  [<ffffffff81269faa>] dpm_suspend_start+0x2e5/0x444
> Feb  3 17:03:11 vanamonde kernel:  [<ffffffff81077c8b>] hibernation_snapshot+0x44/0x1be
> Feb  3 17:03:11 vanamonde kernel:  [<ffffffff81077ece>] hibernate+0xc9/0x16d
> Feb  3 17:03:11 vanamonde kernel:  [<ffffffff81076d33>] state_store+0x57/0xce
> Feb  3 17:03:11 vanamonde kernel:  [<ffffffff811d3fef>] kobj_attr_store+0x17/0x19
> Feb  3 17:03:11 vanamonde kernel:  [<ffffffff8114332a>] sysfs_write_file+0x103/0x13f
> Feb  3 17:03:11 vanamonde kernel:  [<ffffffff810ed676>] vfs_write+0xad/0x172
> Feb  3 17:03:11 vanamonde kernel:  [<ffffffff81068c13>] ? trace_hardirqs_on_caller+0x10c/0x130
> Feb  3 17:03:11 vanamonde kernel:  [<ffffffff810ed7f4>] sys_write+0x45/0x6c
> Feb  3 17:03:11 vanamonde kernel:  [<ffffffff810029ab>] system_call_fastpath+0x16/0x1b
> Feb  3 17:03:11 vanamonde kernel: btusb_intr_complete: hci0 urb ffff8801357f1080 failed to resubmit (1)
> Feb  3 17:03:11 vanamonde kernel: uhci_hcd 0000:00:1a.2: release dev 2 ep81-INT, period 1, phase 0, 23 us
> Feb  3 17:03:11 vanamonde kernel: btusb_bulk_complete: hci0 urb ffff88013967be40 failed to resubmit (1)
> Feb  3 17:03:11 vanamonde kernel: btusb_bulk_complete: hci0 urb ffff88013967bf00 failed to resubmit (1)
> 


-- 
tejun
