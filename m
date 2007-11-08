From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.24-rc1-gb4f5550 oops
Date: Thu, 8 Nov 2007 16:53:10 +0100
Message-ID: <200711081653.11226.rjw@sisk.pl>
References: <20071105061158.3174d24d@worthy.swandive.local> <200711080106.21580.rjw@sisk.pl> <20071108062250.02479c0c@worthy.swandive.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>
To: Grant Wilson <grant.wilson@zen.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:51061 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758614AbXKHPfz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 10:35:55 -0500
In-Reply-To: <20071108062250.02479c0c@worthy.swandive.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, 8 of November 2007, Grant Wilson wrote:
> On Thu, 8 Nov 2007 01:06:21 +0100
> "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> 
> > On Monday, 5 of November 2007, Grant Wilson wrote:
> > > Hi,
> > > I got this oops on 2.6.24-rc1-641-gb4f5550:
> > 
> > (1) Is this reproducible?
> > (2) Did it happen previously on your system?
> >
> > [18073.371126] Unable to handle kernel NULL pointer dereference at 0000000000000120 RIP: 
> > [18073.371134]  [<ffffffff8023572e>] check_preempt_wakeup+0x6e/0x110
> 
> This has now happened twice - the second time was last night when
> running 2.6.24-rc2.
> 
> Here's that second occurrence:
> 
> [ 7224.233621] Unable to handle kernel NULL pointer dereference at 0000000000000120 RIP:
> [ 7224.233631]  [<ffffffff8023572e>] check_preempt_wakeup+0x6e/0x110
> [ 7224.233644] PGD 0
> [ 7224.233650] Oops: 0000 [1] PREEMPT SMP
> [ 7224.233660] CPU 0
> [ 7224.233716] Modules linked in:
> [ 7224.233722] Pid: 7622, comm: ssh Not tainted 2.6.24-rc2 #1
> [ 7224.233726] RIP: 0010:[<ffffffff8023572e>]  [<ffffffff8023572e>] check_preempt_wakeup+0x6e/0x110
> [ 7224.233735] RSP: 0018:ffff81000aafba78  EFLAGS: 00010006
> [ 7224.233738] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000005745
> [ 7224.233743] RDX: ffff81000442fbf0 RSI: ffff810006c96860 RDI: ffff810004438b80
> [ 7224.233748] RBP: ffff81000aafbaa8 R08: 0000007e8e25cf71 R09: 0000000000000000
> [ 7224.233752] R10: ffff81000442fbf0 R11: 0000000000000001 R12: ffff810007479d80
> [ 7224.233756] R13: ffff810006c96860 R14: ffff810009924860 R15: ffff81000442b8e0
> [ 7224.233760] FS:  00002b8bf089d350(0000) GS:ffffffff808d7000(0000) knlGS:0000000000000000
> [ 7224.233764] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 7224.233768] CR2: 0000000000000120 CR3: 000000000ab3f000 CR4: 00000000000006e0
> [ 7224.233771] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 7224.233775] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [ 7224.233779] Process ssh (pid: 7622, threadinfo ffff81000aafa000, task ffff81000abc2000)
> [ 7224.233782] Stack:  ffff810004438b80 0000000000000001 ffff810006c96860 ffff810004438b80
> [ 7224.233796]  0000000000000000 ffff81000442b8e0 ffff81000aafbb38 ffffffff8023061e
> [ 7224.233807]  0000000000000400 ffff81000442fb80 0000000000000000 0000000100000000
> [ 7224.233816] Call Trace:
> [ 7224.233823]  [<ffffffff8023061e>] try_to_wake_up+0x2fe/0x3a0
> [ 7224.233828]  [<ffffffff802306cd>] default_wake_function+0xd/0x10
> [ 7224.233833]  [<ffffffff8022daca>] __wake_up_common+0x5a/0x90
> [ 7224.233839]  [<ffffffff8023095a>] __wake_up_sync+0x4a/0x70
> [ 7224.233845]  [<ffffffff80602fbf>] unix_write_space+0x8f/0xa0
> [ 7224.233850]  [<ffffffff805936f9>] sock_wfree+0x49/0x50
> [ 7224.233854]  [<ffffffff80595579>] __kfree_skb+0x69/0xe0
> [ 7224.233859]  [<ffffffff80595607>] kfree_skb+0x17/0x30
> [ 7224.233863]  [<ffffffff806016c7>] unix_stream_recvmsg+0x267/0x610
> [ 7224.233869]  [<ffffffff8058e457>] sock_aio_read+0x107/0x110
> [ 7224.233875]  [<ffffffff802928f1>] do_sync_read+0xf1/0x130
> [ 7224.233882]  [<ffffffff802a4f20>] __d_free+0x30/0x40
> [ 7224.233887]  [<ffffffff80251830>] autoremove_wake_function+0x0/0x40
> [ 7224.233892]  [<ffffffff80293246>] vfs_read+0x156/0x160
> [ 7224.233897]  [<ffffffff80293650>] sys_read+0x50/0x90
> [ 7224.233901]  [<ffffffff8020bd7e>] system_call+0x7e/0x83
> [ 7224.233904]
> [ 7224.233907]
> [ 7224.233907] Code: 48 8b 90 20 01 00 00 48 39 93 20 01 00 00 75 e2 48 81 3b 00
> [ 7224.233951] RIP  [<ffffffff8023572e>] check_preempt_wakeup+0x6e/0x110
> [ 7224.233957]  RSP <ffff81000aafba78>
> [ 7224.233961] CR2: 0000000000000120
> [ 7224.233967] note: ssh[7622] exited with preempt_count 3

Hmm.

Please run "gdb vmlinux" and see what code corresponds to
check_preempt_wakeup+0x6e in your kernel.
