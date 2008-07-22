From: David Miller <davem@davemloft.net>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
 __netif_schedule+0x2c/0x98()
Date: Tue, 22 Jul 2008 16:04:09 -0700 (PDT)
Message-ID: <20080722.160409.216536011.davem@davemloft.net>
References: <48860D4B.8070003@lwfinger.net>
	<488616C0.8070505@trash.net>
	<4886294C.4060905@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: Larry.Finger@lwfinger.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755370AbYGVXEZ@vger.kernel.org>
In-Reply-To: <4886294C.4060905@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Larry Finger <Larry.Finger@lwfinger.net>
Date: Tue, 22 Jul 2008 13:39:08 -0500

> =============================================
> [ INFO: possible recursive locking detected ]
> 2.6.26-Linus-05752-g93ded9b-dirty #53
> ---------------------------------------------
> b43/1997 is trying to acquire lock:
>   (_xmit_IEEE80211#2){-...}, at: [<ffffffffa028f322>] 
> ieee80211_scan_completed+0x130/0x2e1 [mac80211]
> 
> but task is already holding lock:
>   (_xmit_IEEE80211#2){-...}, at: [<ffffffffa028f322>] 
> ieee80211_scan_completed+0x130/0x2e1 [mac80211]
> 
> other info that might help us debug this:
> 3 locks held by b43/1997:
>   #0:  ((name)){--..}, at: [<ffffffff80245185>] run_workqueue+0xa7/0x1f2
>   #1:  (&(&local->scan_work)->work){--..}, at: [<ffffffff80245185>] 
> run_workqueue+0xa7/0x1f2
>   #2:  (_xmit_IEEE80211#2){-...}, at: [<ffffffffa028f322>] 
> ieee80211_scan_completed+0x130/0x2e1 [mac80211]
> 
> stack backtrace:
> Pid: 1997, comm: b43 Not tainted 2.6.26-Linus-05752-g93ded9b-dirty #53
> 
> Call Trace:
>   [<ffffffff80255616>] __lock_acquire+0xb7b/0xecc
>   [<ffffffff8040c9a0>] __mutex_unlock_slowpath+0x100/0x10b
>   [<ffffffff802559b8>] lock_acquire+0x51/0x6a
>   [<ffffffffa028f322>] ieee80211_scan_completed+0x130/0x2e1 [mac80211]
>   [<ffffffff8040dc08>] _spin_lock+0x1e/0x27
>   [<ffffffffa028f322>] ieee80211_scan_completed+0x130/0x2e1 [mac80211]
>   [<ffffffffa028f6ce>] ieee80211_sta_scan_work+0x0/0x1b8 [mac80211]
>   [<ffffffff802451ce>] run_workqueue+0xf0/0x1f2
>   [<ffffffff802453ab>] worker_thread+0xdb/0xea
>   [<ffffffff80248a5f>] autoremove_wake_function+0x0/0x2e
>   [<ffffffff802452d0>] worker_thread+0x0/0xea
>   [<ffffffff80248731>] kthread+0x47/0x73
>   [<ffffffff8040d7b1>] trace_hardirqs_on_thunk+0x3a/0x3f
>   [<ffffffff8020ceb9>] child_rip+0xa/0x11
>   [<ffffffff8020c4ef>] restore_args+0x0/0x30
>   [<ffffffff802486c5>] kthreadd+0x19a/0x1bf
>   [<ffffffff802486ea>] kthread+0x0/0x73
>   [<ffffffff8020ceaf>] child_rip+0x0/0x11

Lockdep doesn't like that we have an array of objects (the TX queues)
and we're iterating over them grabbing all of their locks.

Does anyone know how to teach lockdep that this is OK?
