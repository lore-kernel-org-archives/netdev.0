From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Soft lockups with dscape on wireless-dev tree
Date: Tue, 23 Jan 2007 12:10:33 -0500
Message-ID: <9e4733910701230910w79a7af45hff626e48a7091ffd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:14964 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932968AbXAWRKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 12:10:34 -0500
Received: by py-out-1112.google.com with SMTP id a29so826384pyi
        for <netdev@vger.kernel.org>; Tue, 23 Jan 2007 09:10:33 -0800 (PST)
To: netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've hit this twice. This time I unplugged my USB hub which had the
device in it.

Jan 23 11:47:08 jonsmirl kernel: BUG: soft lockup detected on CPU#1!
Jan 23 11:47:08 jonsmirl kernel:  [softlockup_tick+156/224]
softlockup_tick+0x9c/0xe0
Jan 23 11:47:08 jonsmirl kernel:  [update_process_times+51/128]
update_process_times+0x33/0x80
Jan 23 11:47:08 jonsmirl kernel:  [smp_apic_timer_interrupt+115/144]
smp_apic_timer_interrupt+0x73/0x90
Jan 23 11:47:08 jonsmirl kernel:  [apic_timer_interrupt+40/48]
apic_timer_interrupt+0x28/0x30
Jan 23 11:47:08 jonsmirl kernel:  [partition_sched_domains+11/96]
partition_sched_domains+0xb/0x60
Jan 23 11:47:08 jonsmirl kernel:  [<f8a4007b>] patch_cr157+0x2b/0xc0
[zd1211rw_d80211]
Jan 23 11:47:08 jonsmirl kernel:  [lock_timer_base+67/80]
lock_timer_base+0x43/0x50
Jan 23 11:47:08 jonsmirl kernel:  [try_to_del_timer_sync+19/80]
try_to_del_timer_sync+0x13/0x50
Jan 23 11:47:08 jonsmirl kernel:  [del_timer_sync+14/32] del_timer_sync+0xe/0x20
Jan 23 11:47:08 jonsmirl kernel:  [<f8a61dfa>]
ieee80211_if_shutdown+0x4a/0x100 [80211]
Jan 23 11:47:08 jonsmirl kernel:  [<f8a65a48>] ieee80211_stop+0x78/0x100 [80211]
Jan 23 11:47:08 jonsmirl kernel:  [dev_close+84/112] dev_close+0x54/0x70
Jan 23 11:47:08 jonsmirl kernel:  [unregister_netdevice+395/528]
unregister_netdevice+0x18b/0x210
Jan 23 11:47:08 jonsmirl kernel:  [<f8a75ff4>]
__ieee80211_if_del+0x34/0x50 [80211]
Jan 23 11:47:08 jonsmirl kernel:  [<f8a65169>]
ieee80211_unregister_hw+0x79/0x210 [80211]
Jan 23 11:47:08 jonsmirl kernel:  [<f8a44a35>] disconnect+0x55/0xc0
[zd1211rw_d80211]
Jan 23 11:47:08 jonsmirl kernel:  [<f88663a8>]
usb_unbind_interface+0x38/0x80 [usbcore]
Jan 23 11:47:08 jonsmirl kernel:  [__device_release_driver+100/144]
__device_release_driver+0x64/0x90
Jan 23 11:47:08 jonsmirl kernel:  [device_release_driver+35/64]
device_release_driver+0x23/0x40
Jan 23 11:47:08 jonsmirl kernel:  [bus_remove_device+92/144]
bus_remove_device+0x5c/0x90
Jan 23 11:47:08 jonsmirl kernel:  [device_del+338/432] device_del+0x152/0x1b0
Jan 23 11:47:08 jonsmirl kernel:  [<f8863c9e>]
usb_disable_device+0x7e/0xe0 [usbcore]
Jan 23 11:47:08 jonsmirl kernel:  [<f8860207>]
usb_disconnect+0x97/0x110 [usbcore]
Jan 23 11:47:08 jonsmirl kernel:  [<f88601f3>]
usb_disconnect+0x83/0x110 [usbcore]
Jan 23 11:47:08 jonsmirl kernel:  [<f8860ede>] hub_thread+0x1ee/0xb70 [usbcore]
Jan 23 11:47:08 jonsmirl kernel:  [autoremove_wake_function+0/80]
autoremove_wake_function+0x0/0x50
Jan 23 11:47:08 jonsmirl kernel:  [<f8860cf0>] hub_thread+0x0/0xb70 [usbcore]
Jan 23 11:47:08 jonsmirl kernel:  [kthread+186/240] kthread+0xba/0xf0
Jan 23 11:47:08 jonsmirl kernel:  [kthread+0/240] kthread+0x0/0xf0
Jan 23 11:47:08 jonsmirl kernel:  [kernel_thread_helper+7/28]
kernel_thread_helper+0x7/0x1c
Jan 23 11:47:08 jonsmirl kernel:  =======================

This one on rmmod of the rt2500 dscape driver

Jan 23 12:02:20 jonsmirl kernel: BUG: soft lockup detected on CPU#0!
Jan 23 12:02:20 jonsmirl kernel:  [softlockup_tick+156/224]
softlockup_tick+0x9c/0xe0
Jan 23 12:02:20 jonsmirl kernel:  [update_process_times+51/128]
update_process_times+0x33/0x80
Jan 23 12:02:20 jonsmirl kernel:  [smp_apic_timer_interrupt+115/144]
smp_apic_timer_interrupt+0x73/0x90
Jan 23 12:02:20 jonsmirl kernel:  [apic_timer_interrupt+40/48]
apic_timer_interrupt+0x28/0x30
Jan 23 12:02:20 jonsmirl kernel:  [lock_timer_base+67/80]
lock_timer_base+0x43/0x50
Jan 23 12:02:20 jonsmirl kernel:  [try_to_del_timer_sync+19/80]
try_to_del_timer_sync+0x13/0x50
Jan 23 12:02:20 jonsmirl kernel:  [del_timer_sync+14/32] del_timer_sync+0xe/0x20
Jan 23 12:02:20 jonsmirl kernel:  [<f8a87dfa>]
ieee80211_if_shutdown+0x4a/0x100 [80211]
Jan 23 12:02:20 jonsmirl kernel:  [<f8a337ad>]
rt2500usb_remove_interface+0xad/0xe0 [rt2500usb]
Jan 23 12:02:20 jonsmirl kernel:  [<f8a8ba48>] ieee80211_stop+0x78/0x100 [80211]
Jan 23 12:02:20 jonsmirl kernel:  [dev_close+84/112] dev_close+0x54/0x70
Jan 23 12:02:20 jonsmirl kernel:  [unregister_netdevice+395/528]
unregister_netdevice+0x18b/0x210
Jan 23 12:02:20 jonsmirl kernel:  [<f8a9bff4>]
__ieee80211_if_del+0x34/0x50 [80211]
Jan 23 12:02:20 jonsmirl kernel:  [<f8a8b169>]
ieee80211_unregister_hw+0x79/0x210 [80211]
Jan 23 12:02:20 jonsmirl kernel:  [<f8a34131>]
rt2500usb_disconnect+0x41/0x70 [rt2500usb]
Jan 23 12:02:20 jonsmirl kernel:  [<f88663a8>]
usb_unbind_interface+0x38/0x80 [usbcore]
Jan 23 12:02:20 jonsmirl kernel:  [__device_release_driver+100/144]
__device_release_driver+0x64/0x90
Jan 23 12:02:20 jonsmirl kernel:  [driver_detach+195/208]
driver_detach+0xc3/0xd0
Jan 23 12:02:20 jonsmirl kernel:  [bus_remove_driver+103/144]
bus_remove_driver+0x67/0x90
Jan 23 12:02:20 jonsmirl kernel:  [driver_unregister+8/32]
driver_unregister+0x8/0x20
Jan 23 12:02:20 jonsmirl kernel:  [<f8865cb6>]
usb_deregister+0x96/0xb0 [usbcore]
Jan 23 12:02:20 jonsmirl kernel:  [sys_delete_module+298/400]
sys_delete_module+0x12a/0x190
Jan 23 12:02:20 jonsmirl kernel:  [zeromap_page_range+354/400]
zeromap_page_range+0x162/0x190
Jan 23 12:02:20 jonsmirl kernel:  [do_munmap+390/480] do_munmap+0x186/0x1e0
Jan 23 12:02:20 jonsmirl kernel:  [sysenter_past_esp+95/133]
sysenter_past_esp+0x5f/0x85
Jan 23 12:02:20 jonsmirl kernel:  [ioctl_standard_call+275/928]
ioctl_standard_call+0x113/0x3a0
Jan 23 12:02:20 jonsmirl kernel:  =======================


-- 
Jon Smirl
jonsmirl@gmail.com
