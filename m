From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330 __netif_schedule+0x2c/0x98()
Date: Tue, 22 Jul 2008 13:39:08 -0500
Message-ID: <4886294C.4060905@lwfinger.net>
References: <4885104A.2070201@lwfinger.net>	<20080721.161517.27161039.davem@davemloft.net>	<48857F74.2040406@lwfinger.net> <20080722.043220.247312412.davem@davemloft.net> <4885DA49.50703@lwfinger.net> <48860D4B.8070003@lwfinger.net> <488616C0.8070505@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:55286 "EHLO
	mtiwmhc11.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754102AbYGVSjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 14:39:11 -0400
In-Reply-To: <488616C0.8070505@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Larry Finger wrote:
>>
>> =============================================
>> [ INFO: possible recursive locking detected ]
>> 2.6.26-Linus-git-05752-g93ded9b #49
> 
>                    ^^^^^^^^^^^^^^ dirty?
> 
> This kernel is not using the patches we sent.

No, but they didn't make any difference. I tried with all 3 applied, then backed 
them out one by one. That was the state when I posted before.

Here are the dumps with all 3 patches applied:

=============================================
[ INFO: possible recursive locking detected ]
2.6.26-Linus-05752-g93ded9b-dirty #53
---------------------------------------------
b43/1997 is trying to acquire lock:
  (_xmit_IEEE80211#2){-...}, at: [<ffffffffa028f322>] 
ieee80211_scan_completed+0x130/0x2e1 [mac80211]

but task is already holding lock:
  (_xmit_IEEE80211#2){-...}, at: [<ffffffffa028f322>] 
ieee80211_scan_completed+0x130/0x2e1 [mac80211]

other info that might help us debug this:
3 locks held by b43/1997:
  #0:  ((name)){--..}, at: [<ffffffff80245185>] run_workqueue+0xa7/0x1f2
  #1:  (&(&local->scan_work)->work){--..}, at: [<ffffffff80245185>] 
run_workqueue+0xa7/0x1f2
  #2:  (_xmit_IEEE80211#2){-...}, at: [<ffffffffa028f322>] 
ieee80211_scan_completed+0x130/0x2e1 [mac80211]

stack backtrace:
Pid: 1997, comm: b43 Not tainted 2.6.26-Linus-05752-g93ded9b-dirty #53

Call Trace:
  [<ffffffff80255616>] __lock_acquire+0xb7b/0xecc
  [<ffffffff8040c9a0>] __mutex_unlock_slowpath+0x100/0x10b
  [<ffffffff802559b8>] lock_acquire+0x51/0x6a
  [<ffffffffa028f322>] ieee80211_scan_completed+0x130/0x2e1 [mac80211]
  [<ffffffff8040dc08>] _spin_lock+0x1e/0x27
  [<ffffffffa028f322>] ieee80211_scan_completed+0x130/0x2e1 [mac80211]
  [<ffffffffa028f6ce>] ieee80211_sta_scan_work+0x0/0x1b8 [mac80211]
  [<ffffffff802451ce>] run_workqueue+0xf0/0x1f2
  [<ffffffff802453ab>] worker_thread+0xdb/0xea
  [<ffffffff80248a5f>] autoremove_wake_function+0x0/0x2e
  [<ffffffff802452d0>] worker_thread+0x0/0xea
  [<ffffffff80248731>] kthread+0x47/0x73
  [<ffffffff8040d7b1>] trace_hardirqs_on_thunk+0x3a/0x3f
  [<ffffffff8020ceb9>] child_rip+0xa/0x11
  [<ffffffff8020c4ef>] restore_args+0x0/0x30
  [<ffffffff802486c5>] kthreadd+0x19a/0x1bf
  [<ffffffff802486ea>] kthread+0x0/0x73
  [<ffffffff8020ceaf>] child_rip+0x0/0x11

------------[ cut here ]------------
WARNING: at net/core/dev.c:1344 __netif_schedule+0x2c/0x98()
Modules linked in: af_packet rfkill_input nfs lockd nfs_acl sunrpc 
cpufreq_conservative cpufreq_userspace cpufreq_powersave powernow_k8 fuse loop 
dm_mod arc4 ecb crypto_blkcipher b43 firmware_class rfkill mac80211 
snd_hda_intel cfg80211 led_class input_polldev k8temp snd_pcm snd_timer battery 
hwmon sr_mod forcedeth ssb joydev ac button serio_raw cdrom snd soundcore 
snd_page_alloc sg sd_mod ohci_hcd ehci_hcd usbcore edd fan thermal processor 
ext3 mbcache jbd pata_amd ahci libata scsi_mod dock
Pid: 1997, comm: b43 Not tainted 2.6.26-Linus-05752-g93ded9b-dirty #53

Call Trace:
  [<ffffffff80235d49>] warn_on_slowpath+0x51/0x8c
  [<ffffffff8040d7b1>] trace_hardirqs_on_thunk+0x3a/0x3f
  [<ffffffff803a2413>] __netif_schedule+0x2c/0x98
  [<ffffffffa028f44d>] ieee80211_scan_completed+0x25b/0x2e1 [mac80211]
  [<ffffffffa028f6ce>] ieee80211_sta_scan_work+0x0/0x1b8 [mac80211]
  [<ffffffff802451ce>] run_workqueue+0xf0/0x1f2
  [<ffffffff802453ab>] worker_thread+0xdb/0xea
  [<ffffffff80248a5f>] autoremove_wake_function+0x0/0x2e
  [<ffffffff802452d0>] worker_thread+0x0/0xea
  [<ffffffff80248731>] kthread+0x47/0x73
  [<ffffffff8040d7b1>] trace_hardirqs_on_thunk+0x3a/0x3f
  [<ffffffff8020ceb9>] child_rip+0xa/0x11
  [<ffffffff8020c4ef>] restore_args+0x0/0x30
  [<ffffffff802486c5>] kthreadd+0x19a/0x1bf
  [<ffffffff802486ea>] kthread+0x0/0x73
  [<ffffffff8020ceaf>] child_rip+0x0/0x11

---[ end trace 88fab857dc2a4242 ]---

Larry




