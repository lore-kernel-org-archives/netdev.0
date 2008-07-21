From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000370
Date: Mon, 21 Jul 2008 15:38:47 -0500
Message-ID: <4884F3D7.4070604@lwfinger.net>
References: <4884DFEE.4060003@lwfinger.net>	<20080721193425.GA29287@elte.hu>	<4884E6E6.7010800@lwfinger.net> <20080721.132100.128525904.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mingo-X9Un+BFzKDI@public.gmane.org, ischram-CNXmb7IdZIWZIoH1IeqzKA@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	j@w1.fi
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080721.132100.128525904.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> 
> No further backtrace?  That will tell us what driver is causing
> this.

Yes, I have a full backtrace.

It starts with possible recursive locking in NetworkManager, and goes directly 
into the Warning - this came from a later pull of Linus's tree.

Jul 21 15:11:07 larrylap kernel: [ INFO: possible recursive locking detected ]
Jul 21 15:11:07 larrylap kernel: 2.6.26-Linus-git-05614-ge89970a #8
Jul 21 15:11:07 larrylap kernel: ---------------------------------------------
Jul 21 15:11:07 larrylap kernel: NetworkManager/2661 is trying to acquire lock:
Jul 21 15:11:07 larrylap kernel:  (&dev->addr_list_lock){-...}, at: 
[<ffffffff803a2961>] dev_mc_sync+0x19/0x57
Jul 21 15:11:07 larrylap kernel:
Jul 21 15:11:07 larrylap kernel: but task is already holding lock:
Jul 21 15:11:07 larrylap kernel:  (&dev->addr_list_lock){-...}, at: 
[<ffffffff8039e7c5>] dev_set_rx_mode+0x19/0x2e
Jul 21 15:11:07 larrylap kernel:
Jul 21 15:11:07 larrylap kernel: other info that might help us debug this:
Jul 21 15:11:07 larrylap kernel: 2 locks held by NetworkManager/2661:
Jul 21 15:11:07 larrylap kernel:  #0:  (rtnl_mutex){--..}, at: 
[<ffffffff803a8318>] rtnetlink_rcv+0x12/0x27
Jul 21 15:11:07 larrylap kernel:  #1:  (&dev->addr_list_lock){-...}, at: 
[<ffffffff8039e7c5>] dev_set_rx_mode+0x19/0x2e
Jul 21 15:11:07 larrylap kernel:
Jul 21 15:11:07 larrylap kernel: stack backtrace:
Jul 21 15:11:07 larrylap kernel: Pid: 2661, comm: NetworkManager Not tainted 
2.6.26-Linus-git-05614-ge89970a #8
Jul 21 15:11:07 larrylap kernel:
Jul 21 15:11:07 larrylap kernel: Call Trace:
Jul 21 15:11:07 larrylap kernel:  [<ffffffff80251b02>] __lock_acquire+0xb7b/0xecc
Jul 21 15:11:07 larrylap kernel:  [<ffffffff80251ea4>] lock_acquire+0x51/0x6a
Jul 21 15:11:07 larrylap kernel:  [<ffffffff803a2961>] dev_mc_sync+0x19/0x57
Jul 21 15:11:07 larrylap kernel:  [<ffffffff80408f9c>] _spin_lock_bh+0x23/0x2c
Jul 21 15:11:07 larrylap kernel:  [<ffffffff803a2961>] dev_mc_sync+0x19/0x57
Jul 21 15:11:07 larrylap kernel:  [<ffffffff8039e7cd>] dev_set_rx_mode+0x21/0x2e
Jul 21 15:11:07 larrylap kernel:  [<ffffffff803a036c>] dev_open+0x8e/0xb0
Jul 21 15:11:07 larrylap kernel:  [<ffffffff8039fd13>] dev_change_flags+0xa6/0x164
Jul 21 15:11:07 larrylap kernel:  [<ffffffff803a7421>] do_setlink+0x286/0x349
Jul 21 15:11:07 larrylap kernel:  [<ffffffff803a832d>] rtnetlink_rcv_msg+0x0/0x1ec
Jul 21 15:11:07 larrylap syslog-ng[2488]: last message repeated 2 times
Jul 21 15:11:07 larrylap kernel:  [<ffffffff803a766e>] rtnl_setlink+0x10b/0x10d
Jul 21 15:11:07 larrylap kernel:  [<ffffffff803a832d>] rtnetlink_rcv_msg+0x0/0x1ec
Jul 21 15:11:07 larrylap kernel:  [<ffffffff803b1bcf>] netlink_rcv_skb+0x34/0x7d
Jul 21 15:11:07 larrylap kernel:  [<ffffffff803a8327>] rtnetlink_rcv+0x21/0x27
Jul 21 15:11:07 larrylap kernel:  [<ffffffff803b16cf>] netlink_unicast+0x1f0/0x261
Jul 21 15:11:07 larrylap kernel:  [<ffffffff8039a448>] __alloc_skb+0x66/0x12a
Jul 21 15:11:07 larrylap kernel:  [<ffffffff803b19a8>] netlink_sendmsg+0x268/0x27b
Jul 21 15:11:07 larrylap rpc.idmapd[2783]: main: 
fcntl(/var/lib/nfs/rpc_pipefs/nfs): Invalid argument
Jul 21 15:11:07 larrylap kernel:  [<ffffffff80393b8d>] sock_sendmsg+0xcb/0xe3
Jul 21 15:11:07 larrylap kernel:  [<ffffffff80246aab>] 
autoremove_wake_function+0x0/0x2e
Jul 21 15:11:07 larrylap kernel:  [<ffffffff8039b194>] verify_iovec+0x46/0x82
Jul 21 15:11:07 larrylap kernel:  [<ffffffff80393dbc>] sys_sendmsg+0x217/0x28a
Jul 21 15:11:07 larrylap kernel:  [<ffffffff80393516>] sockfd_lookup_light+0x1a/0x52
Jul 21 15:11:07 larrylap kernel:  [<ffffffff80250990>] 
trace_hardirqs_on_caller+0xef/0x113
Jul 21 15:11:07 larrylap kernel:  [<ffffffff80408b14>] 
trace_hardirqs_on_thunk+0x3a/0x3f
Jul 21 15:11:07 larrylap kernel:  [<ffffffff8020be9b>] 
system_call_after_swapgs+0x7b/0x80
Jul 21 15:11:07 larrylap kernel:
Jul 21 15:11:07 larrylap kernel: NET: Registered protocol family 17
Jul 21 15:11:08 larrylap kernel: ------------[ cut here ]------------
Jul 21 15:11:08 larrylap kernel: WARNING: at net/core/dev.c:1330 
__netif_schedule+0x2c/0x98()
Jul 21 15:11:08 larrylap kernel: Modules linked in: snd_seq_device af_packet nfs 
lockd nfs_acl sunrpc rfkill_input cpufreq_conservative cpufreq_userspace 
cpufreq_powersave powernow_k8 fuse loop dm_mod arc4 ecb crypto_blkcipher b43 
firmware_class rfkill snd_hda_intel mac80211 cfg80211 snd_pcm snd_timer 
led_class snd soundcore input_polldev ac k8temp button snd_page_alloc battery 
sr_mod forcedeth cdrom serio_raw hwmon ssb sg ehci_hcd sd_mod ohci_hcd usbcore 
edd fan thermal processor ext3 mbcache jbd pata_amd ahci libata scsi_mod dock
Jul 21 15:11:08 larrylap kernel: Pid: 2035, comm: b43 Not tainted 
2.6.26-Linus-git-05614-ge89970a #8
Jul 21 15:11:08 larrylap kernel:
Jul 21 15:11:08 larrylap kernel: Call Trace:
Jul 21 15:11:08 larrylap kernel:  [<ffffffff80233f6d>] warn_on_slowpath+0x51/0x8c
Jul 21 15:11:08 larrylap kernel:  [<ffffffff8039d7f3>] __netif_schedule+0x2c/0x98
Jul 21 15:11:08 larrylap kernel:  [<ffffffffa018b44d>] 
ieee80211_scan_completed+0x25b/0x2e1 [mac80211]
Jul 21 15:11:08 larrylap kernel:  [<ffffffffa018b6ce>] 
ieee80211_sta_scan_work+0x0/0x1b8 [mac80211]
Jul 21 15:11:08 larrylap kernel:  [<ffffffff8024325e>] run_workqueue+0xf0/0x1f2
Jul 21 15:11:08 larrylap kernel:  [<ffffffff8024343b>] worker_thread+0xdb/0xea
Jul 21 15:11:08 larrylap kernel:  [<ffffffff80246aab>] 
autoremove_wake_function+0x0/0x2e
Jul 21 15:11:08 larrylap avahi-daemon[2877]: Found user 'avahi' (UID 102) and 
group 'avahi' (GID 104).
Jul 21 15:11:09 larrylap kernel:  [<ffffffff80243360>] worker_thread+0x0/0xea
Jul 21 15:11:09 larrylap kernel:  [<ffffffff8024678b>] kthread+0x47/0x73
Jul 21 15:11:09 larrylap avahi-daemon[2877]: Successfully dropped root privileges.
Jul 21 15:11:09 larrylap kernel:  [<ffffffff80408b14>] 
trace_hardirqs_on_thunk+0x3a/0x3f
Jul 21 15:11:09 larrylap avahi-daemon[2877]: avahi-daemon 0.6.22 starting up.
Jul 21 15:11:09 larrylap kernel:  [<ffffffff8020cea9>] child_rip+0xa/0x11
Jul 21 15:11:09 larrylap kernel:  [<ffffffff8020c4df>] restore_args+0x0/0x30
Jul 21 15:11:09 larrylap kernel:  [<ffffffff8024671f>] kthreadd+0x188/0x1ad
Jul 21 15:11:09 larrylap kernel:  [<ffffffff80246744>] kthread+0x0/0x73
Jul 21 15:11:09 larrylap kernel:  [<ffffffff8020ce9f>] child_rip+0x0/0x11
Jul 21 15:11:09 larrylap kernel:
Jul 21 15:11:09 larrylap kernel: ---[ end trace 030d0589d3c6c7f5 ]---


Larry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
