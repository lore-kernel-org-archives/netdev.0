From: f6bvp <f6bvp@free.fr>
Subject: khubd  [ INFO: possible circular locking dependency detected ]
Date: Thu, 16 Jun 2011 22:29:29 +0200
Message-ID: <4DFA67A9.70600@free.fr>
References: <4B2CD772.1030106@upmc.fr> <4B2D1025.1020106@gmail.com> <4B2E6729.1090102@free.fr> <4B507FAA.8010007@free.fr> <20100115203654.GA3084@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:39127 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932720Ab1FPU3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2011 16:29:38 -0400
In-Reply-To: <20100115203654.GA3084@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Here is a kernel message dump reporting a possible circular locking :

Jun 13 11:58:55 f6bvp-9 kernel: usb 5-2: New USB device strings: Mfr=1, 
Product=2, SerialNumber=0
Jun 13 11:58:55 f6bvp-9 kernel: usb 5-2: Product: FUNcube Dongle V1.0
Jun 13 11:58:55 f6bvp-9 kernel: usb 5-2: Manufacturer: Hanlincrest Ltd. 

Jun 13 11:58:55 f6bvp-9 kernel: generic-usb 0003:04D8:FB56.0004: 
hiddev0,hidraw3: USB HID v1.11 Device [Hanlincrest Ltd.          FUNcube 
Dongle V1.0  ] on usb-0000:00:1d.3-2/input2
Jun 13 11:58:56 f6bvp-9 kernel: usbcore: registered new interface driver 
snd-usb-audio
Jun 13 11:58:56 f6bvp-9 udevd-work[11414]: symlink(snd/controlC1, 
/dev/FCD.udev-tmp) failed: File exists
Jun 13 11:58:57 f6bvp-9 rtkit-daemon[3119]: Successfully made thread 
11434 of process 3117 (/usr/bin/pulseaudio) owned by '500' RT at priority 5.
Jun 13 11:59:18 f6bvp-9 kernel: usb 5-2: USB disconnect, device number 2
Jun 13 11:59:18 f6bvp-9 kernel:
Jun 13 11:59:18 f6bvp-9 kernel: 
=======================================================
Jun 13 11:59:18 f6bvp-9 kernel: [ INFO: possible circular locking 
dependency detected ]
Jun 13 11:59:18 f6bvp-9 kernel: 2.6.39 #2
Jun 13 11:59:18 f6bvp-9 kernel: 
-------------------------------------------------------
Jun 13 11:59:18 f6bvp-9 kernel: khubd/41 is trying to acquire lock:
Jun 13 11:59:18 f6bvp-9 kernel: (sound_oss_mutex){+.+.+.}, at: 
[<ffffffffa02e134b>] snd_unregister_oss_device+0x4b/0x110 [snd]
Jun 13 11:59:18 f6bvp-9 kernel:
Jun 13 11:59:18 f6bvp-9 kernel: but task is already holding lock:
Jun 13 11:59:18 f6bvp-9 kernel: (&chip->shutdown_mutex){+.+.+.}, at: 
[<ffffffffa05e3258>] usb_audio_disconnect+0x48/0x1b0 [snd_usb_audio]
Jun 13 11:59:18 f6bvp-9 kernel:
Jun 13 11:59:18 f6bvp-9 kernel: which lock already depends on the new lock.
Jun 13 11:59:18 f6bvp-9 kernel:
Jun 13 11:59:18 f6bvp-9 kernel:
Jun 13 11:59:18 f6bvp-9 kernel: the existing dependency chain (in 
reverse order) is:
Jun 13 11:59:18 f6bvp-9 kernel:
Jun 13 11:59:18 f6bvp-9 kernel: -> #5 (&chip->shutdown_mutex){+.+.+.}:
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff810958d6>] 
lock_acquire+0xa6/0x160
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff813f469c>] 
__mutex_lock_common+0x4c/0x3c0
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff813f4ac5>] 
mutex_lock_nested+0x35/0x40
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffffa05ed874>] 
snd_usb_hw_free+0x44/0x70 [snd_usb_audio]
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffffa02f3523>] 
snd_pcm_release_substream+0x63/0xc0 [snd_pcm]
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffffa02f35d0>] 
snd_pcm_release+0x50/0xe0 [snd_pcm]
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff8114303a>] fput+0xea/0x230
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff811185e5>] 
remove_vma+0x45/0x90
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff8111a378>] 
do_munmap+0x318/0x3b0
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff8111a469>] 
sys_munmap+0x59/0x80
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff813fe5d2>] 
system_call_fastpath+0x16/0x1b
Jun 13 11:59:18 f6bvp-9 kernel:
Jun 13 11:59:18 f6bvp-9 kernel: -> #4 (&pcm->open_mutex){+.+.+.}:
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff810958d6>] 
lock_acquire+0xa6/0x160
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff813f469c>] 
__mutex_lock_common+0x4c/0x3c0
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff813f4ac5>] 
mutex_lock_nested+0x35/0x40
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffffa02f35c8>] 
snd_pcm_release+0x48/0xe0 [snd_pcm]
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff8114303a>] fput+0xea/0x230
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff811185e5>] 
remove_vma+0x45/0x90
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff8111a378>] 
do_munmap+0x318/0x3b0
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff8111a469>] 
sys_munmap+0x59/0x80
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff813fe5d2>] 
system_call_fastpath+0x16/0x1b
Jun 13 11:59:18 f6bvp-9 kernel:
Jun 13 11:59:18 f6bvp-9 kernel: -> #3 (&mm->mmap_sem){++++++}:
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff810958d6>] 
lock_acquire+0xa6/0x160
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff811106e2>] 
might_fault+0x72/0xa0
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff81153642>] filldir+0x82/0xf0
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff81165dee>] 
dcache_readdir+0x5e/0x260
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff81153848>] 
vfs_readdir+0xb8/0xe0
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff811539d9>] 
sys_getdents+0x89/0xf0
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff813fe5d2>] 
system_call_fastpath+0x16/0x1b
Jun 13 11:59:18 f6bvp-9 kernel:
Jun 13 11:59:18 f6bvp-9 kernel: -> #2 (&sb->s_type->i_mutex_key#3){+.+.+.}:
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff810958d6>] 
lock_acquire+0xa6/0x160
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff813f469c>] 
__mutex_lock_common+0x4c/0x3c0
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff813f4ac5>] 
mutex_lock_nested+0x35/0x40
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff812d0412>] 
devtmpfs_create_node+0x1f2/0x290
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff812c90a8>] 
device_add+0x218/0x6e0
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff812c958e>] 
device_register+0x1e/0x30
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff812c96b0>] 
device_create_vargs+0x110/0x120
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff812c96f1>] 
device_create+0x31/0x40
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff812bc392>] 
misc_register+0x92/0x140
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff817478c0>] 
vga_arb_device_init+0x13/0x77
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff81002043>] 
do_one_initcall+0x43/0x190
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff81713655>] 
kernel_init+0xb5/0x135
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff813ff764>] 
kernel_thread_helper+0x4/0x10
Jun 13 11:59:18 f6bvp-9 kernel:
Jun 13 11:59:18 f6bvp-9 kernel: -> #1 
(&sb->s_type->i_mutex_key#2/1){+.+.+.}:
Jun 13 11:59:18 f6bvp-9 kernel:       [<ffffffff810958d6>] 
lock_acquire+0xa6/0x160
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff813f469c>] 
__mutex_lock_common+0x4c/0x3c0
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff813f4ac5>] 
mutex_lock_nested+0x35/0x40
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff8114bcb2>] 
lookup_create+0x32/0xd0
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff812d032a>] 
devtmpfs_create_node+0x10a/0x290
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff812c90a8>] 
device_add+0x218/0x6e0
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff812c958e>] 
device_register+0x1e/0x30
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff812c96b0>] 
device_create_vargs+0x110/0x120
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff812c96f1>] 
device_create+0x31/0x40
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffffa017c44c>] 
sound_insert_unit+0x29c/0x300 [soundcore]
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffffa017c644>] 
register_sound_special_device+0xb4/0x240 [soundcore]
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffffa02e152c>] 
snd_register_oss_device+0x11c/0x220 [snd]
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffffa038103b>] 
0xffffffffa038103b
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff81002043>] 
do_one_initcall+0x43/0x190
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff810a200a>] 
sys_init_module+0xba/0x200
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff813fe5d2>] 
system_call_fastpath+0x16/0x1b
Jun 13 11:59:19 f6bvp-9 kernel:
Jun 13 11:59:19 f6bvp-9 kernel: -> #0 (sound_oss_mutex){+.+.+.}:
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff8109571d>] 
__lock_acquire+0x13ad/0x14c0
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff810958d6>] 
lock_acquire+0xa6/0x160
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff813f469c>] 
__mutex_lock_common+0x4c/0x3c0
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff813f4ac5>] 
mutex_lock_nested+0x35/0x40
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffffa02e134b>] 
snd_unregister_oss_device+0x4b/0x110 [snd]
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffffa01de5dd>] 
snd_mixer_oss_notify_handler+0x11d/0x330 [snd_mixer_oss]
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffffa02dae5f>] 
snd_card_disconnect+0x16f/0x250 [snd]
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffffa05e32a0>] 
usb_audio_disconnect+0x90/0x1b0 [snd_usb_audio]
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffffa000ccc0>] 
usb_unbind_interface+0x60/0x1a0 [usbcore]
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff812cb525>] 
__device_release_driver+0x75/0xe0
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff812cbacf>] 
device_release_driver+0x2f/0x50
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff812ca564>] 
bus_remove_device+0xb4/0x100
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff812c878f>] 
device_del+0x12f/0x1b0
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffffa0009b1f>] 
usb_disable_device+0x6f/0x130 [usbcore]
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffffa0003b99>] 
usb_disconnect+0x99/0x130 [usbcore]
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffffa00044e1>] 
hub_thread+0x621/0x12d0 [usbcore]
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff8107d816>] kthread+0xb6/0xc0
Jun 13 11:59:19 f6bvp-9 kernel:       [<ffffffff813ff764>] 
kernel_thread_helper+0x4/0x10
Jun 13 11:59:19 f6bvp-9 kernel:
Jun 13 11:59:19 f6bvp-9 kernel: other info that might help us debug this:
Jun 13 11:59:19 f6bvp-9 kernel:
Jun 13 11:59:19 f6bvp-9 kernel: 5 locks held by khubd/41:
Jun 13 11:59:19 f6bvp-9 kernel: #0:  (&__lockdep_no_validate__){+.+.+.}, 
at: [<ffffffffa0003ff0>] hub_thread+0x130/0x12d0 [usbcore]
Jun 13 11:59:19 f6bvp-9 kernel: #1:  (&__lockdep_no_validate__){+.+.+.}, 
at: [<ffffffffa0003b5d>] usb_disconnect+0x5d/0x130 [usbcore]
Jun 13 11:59:19 f6bvp-9 kernel: #2:  (&__lockdep_no_validate__){+.+.+.}, 
at: [<ffffffff812cbac7>] device_release_driver+0x27/0x50
Jun 13 11:59:19 f6bvp-9 kernel: #3:  (register_mutex#6){+.+.+.}, at: 
[<ffffffffa05e324e>] usb_audio_disconnect+0x3e/0x1b0 [snd_usb_audio]
Jun 13 11:59:19 f6bvp-9 kernel: #4:  (&chip->shutdown_mutex){+.+.+.}, 
at: [<ffffffffa05e3258>] usb_audio_disconnect+0x48/0x1b0 [snd_usb_audio]
Jun 13 11:59:19 f6bvp-9 kernel:
Jun 13 11:59:19 f6bvp-9 kernel: stack backtrace:
Jun 13 11:59:19 f6bvp-9 kernel: Pid: 41, comm: khubd Not tainted 2.6.39 #2
Jun 13 11:59:19 f6bvp-9 kernel: Call Trace:
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff81093299>] 
print_circular_bug+0xe9/0xf0
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff8109571d>] 
__lock_acquire+0x13ad/0x14c0
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff810958d6>] lock_acquire+0xa6/0x160
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffffa02e134b>] ? 
snd_unregister_oss_device+0x4b/0x110 [snd]
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff81093d6b>] ? 
mark_held_locks+0x6b/0xa0
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff813f469c>] 
__mutex_lock_common+0x4c/0x3c0
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffffa02e134b>] ? 
snd_unregister_oss_device+0x4b/0x110 [snd]
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffffa02e134b>] ? 
snd_unregister_oss_device+0x4b/0x110 [snd]
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff813f4403>] ? 
__mutex_unlock_slowpath+0xd3/0x170
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff8109406d>] ? 
trace_hardirqs_on_caller+0x13d/0x180
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff813f4ac5>] 
mutex_lock_nested+0x35/0x40
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffffa02e134b>] 
snd_unregister_oss_device+0x4b/0x110 [snd]
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffffa01de5dd>] 
snd_mixer_oss_notify_handler+0x11d/0x330 [snd_mixer_oss]
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffffa02dadb8>] ? 
snd_card_disconnect+0xc8/0x250 [snd]
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff813f4403>] ? 
__mutex_unlock_slowpath+0xd3/0x170
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff8109406d>] ? 
trace_hardirqs_on_caller+0x13d/0x180
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffffa02dae5f>] 
snd_card_disconnect+0x16f/0x250 [snd]
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffffa05e32a0>] 
usb_audio_disconnect+0x90/0x1b0 [snd_usb_audio]
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffffa000ccc0>] 
usb_unbind_interface+0x60/0x1a0 [usbcore]
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff812cb525>] 
__device_release_driver+0x75/0xe0
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff812cbacf>] 
device_release_driver+0x2f/0x50
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff812ca564>] 
bus_remove_device+0xb4/0x100
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff812c878f>] device_del+0x12f/0x1b0
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffffa0009b1f>] 
usb_disable_device+0x6f/0x130 [usbcore]
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffffa0003b99>] 
usb_disconnect+0x99/0x130 [usbcore]
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffffa00044e1>] 
hub_thread+0x621/0x12d0 [usbcore]
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff813f6380>] ? 
_raw_spin_unlock_irq+0x30/0x40
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff8104acad>] ? 
finish_task_switch+0x7d/0x110
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff8104ac78>] ? 
finish_task_switch+0x48/0x110
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffffa0003ec0>] ? 
hub_disconnect+0x120/0x120 [usbcore]
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff8107dd50>] ? wake_up_bit+0x40/0x40
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffffa0003ec0>] ? 
hub_disconnect+0x120/0x120 [usbcore]
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff8107d816>] kthread+0xb6/0xc0
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff8109406d>] ? 
trace_hardirqs_on_caller+0x13d/0x180
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff813ff764>] 
kernel_thread_helper+0x4/0x10
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff813f6794>] ? 
retint_restore_args+0x13/0x13
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff8107d760>] ? 
__init_kthread_worker+0x70/0x70
Jun 13 11:59:19 f6bvp-9 kernel: [<ffffffff813ff760>] ? gs_change+0x13/0x13
Jun 13 11:59:20 f6bvp-9 kernel: usb 5-1: new full speed USB device 
number 3 using uhci_hcd
Jun 13 11:59:20 f6bvp-9 kernel: usb 5-1: New USB device found, 
idVendor=04d8, idProduct=fb56
Jun 13 11:59:20 f6bvp-9 kernel: usb 5-1: New USB device strings: Mfr=1, 
Product=2, SerialNumber=0
Jun 13 11:59:20 f6bvp-9 kernel: usb 5-1: Product: FUNcube Dongle V1.0
Jun 13 11:59:20 f6bvp-9 kernel: usb 5-1: Manufacturer: Hanlincrest Ltd. 

Jun 13 11:59:20 f6bvp-9 kernel: generic-usb 0003:04D8:FB56.0005: 
hiddev0,hidraw3: USB HID v1.11 Device [Hanlincrest Ltd.          FUNcube 
Dongle V1.0  ] on usb-0000:00:1d.3-1/input2
Jun 13 11:59:21 f6bvp-9 rtkit-daemon[3119]: Successfully made thread 
12523 of process 3117 (/usr/bin/pulseaudio) owned by '500' RT at priority 5.
Jun 13 11:59:22 f6bvp-9 kernel: hald-probe-hidd: page allocation 
failure. order:4, mode:0xc0d0
Jun 13 11:59:22 f6bvp-9 kernel: Pid: 12500, comm: hald-probe-hidd Not 
tainted 2.6.39 #2
Jun 13 11:59:22 f6bvp-9 kernel: Call Trace:
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffff810f8482>] 
__alloc_pages_nodemask+0x612/0x820
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffff8112d4af>] 
alloc_pages_current+0x8f/0xe0
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffff810f757e>] 
__get_free_pages+0xe/0x50
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffff8113549e>] 
kmalloc_order_trace+0x3e/0xb0
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffffa0000a80>] ? 
usb_find_interface+0x40/0x60 [usbcore]
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffffa005ecd4>] 
hiddev_open+0x74/0x1c0 [usbhid]
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffff813f4e69>] ? down_read+0x39/0x50
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffffa000f464>] ? 
usb_open+0x44/0x1a0 [usbcore]
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffffa000f4e8>] usb_open+0xc8/0x1a0 
[usbcore]
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffff811452b7>] chrdev_open+0xf7/0x210
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffff811451c0>] ? cdev_alloc+0x60/0x60
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffff8113f146>] 
__dentry_open+0x146/0x310
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffff8113f411>] 
nameidata_to_filp+0x71/0x80
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffff8114e79c>] do_last+0x1ec/0x870
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffff8114f980>] path_openat+0xd0/0x430
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffff8114fdf9>] do_filp_open+0x49/0xa0
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffff813f642b>] ? 
_raw_spin_unlock+0x2b/0x40
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffff8115d8fa>] ? alloc_fd+0xfa/0x140
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffff811407b7>] do_sys_open+0x107/0x1e0
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffff811408d0>] sys_open+0x20/0x30
Jun 13 11:59:22 f6bvp-9 kernel: [<ffffffff813fe5d2>] 
system_call_fastpath+0x16/0x1b
Jun 13 11:59:22 f6bvp-9 kernel: Mem-Info:
Jun 13 11:59:22 f6bvp-9 kernel: Node 0 DMA per-cpu:
Jun 13 11:59:22 f6bvp-9 kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jun 13 11:59:22 f6bvp-9 kernel: CPU    1: hi:    0, btch:   1 usd:   0
Jun 13 11:59:22 f6bvp-9 kernel: Node 0 DMA32 per-cpu:
Jun 13 11:59:22 f6bvp-9 kernel: CPU    0: hi:  186, btch:  31 usd:   0
Jun 13 11:59:22 f6bvp-9 kernel: CPU    1: hi:  186, btch:  31 usd:   0
Jun 13 11:59:22 f6bvp-9 kernel: active_anon:21438 inactive_anon:41165 
isolated_anon:11
Jun 13 11:59:22 f6bvp-9 kernel: active_file:50805 inactive_file:93727 
isolated_file:31
Jun 13 11:59:22 f6bvp-9 kernel: unevictable:0 dirty:19022 writeback:359 
unstable:0
Jun 13 11:59:22 f6bvp-9 kernel: free:18969 slab_reclaimable:12604 
slab_unreclaimable:4850
Jun 13 11:59:22 f6bvp-9 kernel: mapped:6458 shmem:849 pagetables:3938 
bounce:0
Jun 13 11:59:22 f6bvp-9 kernel: Node 0 DMA free:4048kB min:60kB low:72kB 
high:88kB active_anon:0kB inactive_anon:72kB active_file:2656kB 
inactive_file:7768kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:15624kB mlocked:0kB dirty:0kB writeback:0kB 
mapped:124kB shmem:0kB slab_reclaimable:1252kB slab_unreclaimable:48kB 
kernel_stack:0kB pagetables:4kB unstable:0kB bounce:0kB 
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Jun 13 11:59:22 f6bvp-9 kernel: lowmem_reserve[]: 0 992 992 992
Jun 13 11:59:22 f6bvp-9 kernel: Node 0 DMA32 free:71828kB min:3996kB 
low:4992kB high:5992kB active_anon:85752kB inactive_anon:164588kB 
active_file:200564kB inactive_file:367140kB unevictable:0kB 
isolated(anon):44kB isolated(file):124kB present:1016072kB mlocked:0kB 
dirty:76088kB writeback:1436kB mapped:25708kB shmem:3396kB 
slab_reclaimable:49164kB slab_unreclaimable:19352kB kernel_stack:2312kB 
pagetables:15748kB unstable:0kB bounce:0kB writeback_tmp:0kB 
pages_scanned:0 all_unreclaimable? no
Jun 13 11:59:22 f6bvp-9 kernel: lowmem_reserve[]: 0 0 0 0
Jun 13 11:59:22 f6bvp-9 kernel: Node 0 DMA: 114*4kB 45*8kB 14*16kB 
6*32kB 8*64kB 2*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 4048kB
Jun 13 11:59:22 f6bvp-9 kernel: Node 0 DMA32: 3925*4kB 3502*8kB 
1643*16kB 55*32kB 1*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 
0*4096kB = 71828kB
Jun 13 11:59:22 f6bvp-9 kernel: 150823 total pagecache pages
Jun 13 11:59:22 f6bvp-9 kernel: 5394 pages in swap cache


Regards,

Bernard Pidoux


