From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000370
Date: Tue, 22 Jul 2008 07:52:24 -0500
Message-ID: <4885D808.9060203@lwfinger.net>
References: <4885104A.2070201@lwfinger.net>	<20080721.161517.27161039.davem@davemloft.net>	<48857F74.2040406@lwfinger.net> <20080722.043220.247312412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, mingo@elte.hu, ischram@telenet.be,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, j@w1.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:50736 "EHLO
	mtiwmhc12.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752022AbYGVMw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 08:52:27 -0400
In-Reply-To: <20080722.043220.247312412.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Larry Finger <Larry.Finger@lwfinger.net>
> Date: Tue, 22 Jul 2008 01:34:28 -0500
> 
>> David Miller wrote:
>>> From: Larry Finger <Larry.Finger@lwfinger.net>
>>> Date: Mon, 21 Jul 2008 17:40:10 -0500
>>>
>>>> Sorry :(
>>>>
>>>> I used the davem patch, the second version of your first one, and your second 
>>>> one. Both problems persist.
>>>>
>>>> Still plugging away on bisection.
>>> GIT bisecting the lockdep problem is surely going the land you on:
>>>
>>> commit e308a5d806c852f56590ffdd3834d0df0cbed8d7
>> No. It landed on this one.
> 
> For the lockdep warnings?

No - this one triggers the kernel BUG as follows:

------------[ cut here ]------------
kernel BUG at net/core/dev.c:1328!
invalid opcode: 0000 [1] SMP
CPU 0
Modules linked in: af_packet rfkill_input nfs lockd nfs_acl sunrpc 
cpufreq_conservative cpufreq_userspace cpufreq_powersave powernow_k8 fuse loop 
dm_mod arc4 ecb crypto_blkcipher b43 firmware_class rfkill mac80211 cfg80211 
led_class input_polldev k8temp sr_mod battery ac ssb button hwmon forcedeth 
cdrom serio_raw sg ohci_hcd ehci_hcd sd_mod usbcore edd fan thermal processor 
ext3 mbcache jbd pata_amd ahci libata scsi_mod dock
Pid: 2003, comm: b43 Not tainted 2.6.26-rc8-Linus-git-01424-g37437bb #43
RIP: 0010:[<ffffffff803958c6>]  [<ffffffff803958c6>] __netif_schedule+0x12/0x75
RSP: 0018:ffff8100b9e33de0  EFLAGS: 00010246
RAX: ffff8100b63819c0 RBX: ffffffff80545300 RCX: ffff8100b6381980
RDX: 00000000ffffffff RSI: 0000000000000001 RDI: ffffffff80545300
RBP: ffff8100b7b45158 R08: ffff8100b89d8000 R09: ffff8100b9d26000
R10: ffff8100b7b44480 R11: ffffffffa01239ef R12: ffff8100b7b44480
R13: ffff8100b9d26000 R14: ffff8100b89d8000 R15: 0000000000000000
FS:  00007f494406a6f0(0000) GS:ffffffff8055e000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00007f49440933dc CR3: 0000000000201000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process b43 (pid: 2003, threadinfo ffff8100b9e32000, task ffff8100b4a3e480)
Stack:  ffff8100b7b45158 ffff8100b89d8900 ffff8100b7b45158 ffffffffa0158455
  ffff8100ba3287c0 0000000000000246 0000000000000000 0000000000000000
  ffff8100b9e33e70 ffff8100b7b451b8 ffff8100ba3287c0 ffff8100b7b451b0
Call Trace:
  [<ffffffffa0158455>] ? :mac80211:ieee80211_scan_completed+0x25b/0x2e1
  [<ffffffffa01586d6>] ? :mac80211:ieee80211_sta_scan_work+0x0/0x1b8
  [<ffffffff8023f7d7>] ? run_workqueue+0xf1/0x1f3
  [<ffffffff8023f9b4>] ? worker_thread+0xdb/0xea
  [<ffffffff80243017>] ? autoremove_wake_function+0x0/0x2e
  [<ffffffff8023f8d9>] ? worker_thread+0x0/0xea
  [<ffffffff80242cff>] ? kthread+0x47/0x73
  [<ffffffff80402845>] ? trace_hardirqs_on_thunk+0x35/0x3a
  [<ffffffff8020cd48>] ? child_rip+0xa/0x12
  [<ffffffff8020c45f>] ? restore_args+0x0/0x30
  [<ffffffff8021d3b6>] ? flat_send_IPI_mask+0x0/0x67
  [<ffffffff80242c93>] ? kthreadd+0x188/0x1ad
  [<ffffffff80242c93>] ? kthreadd+0x188/0x1ad
  [<ffffffff80242cb8>] ? kthread+0x0/0x73
  [<ffffffff8020cd3e>] ? child_rip+0x0/0x12


Code: 00 00 75 0a 55 9d 5e 5b 5d e9 32 64 eb ff e8 21 73 eb ff 55 9d 59 5b 5d c3 
55 53 48 89 fb 48 83 ec 08 48 81 ff 00 53 54 80 75 04 <0f> 0b eb fe 48 8d 47 30 
f0 0f ba 28 01 19 d2 85 d2 75 4c 9c 5d
RIP  [<ffffffff803958c6>] __netif_schedule+0x12/0x75
  RSP <ffff8100b9e33de0>
---[ end trace 396dc6bdf73da468 ]---

I'll have to trace back to see which of the bisections produced both the lockdep 
and the kernel bug.

Larry


