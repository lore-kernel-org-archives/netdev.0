From: Hariprasad S <hariprasad@chelsio.com>
Subject: Re: [PATCH] cxgb4: disable BH when hold the adap_rcu_lock lock
Date: Thu, 19 Jun 2014 19:25:00 +0530
Message-ID: <20140619135500.GA25925@hariprasad-pc>
References: <53A0DDF5.80103@candelatech.com>
 <1403168810-9001-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <greearb@candelatech.com>,
	<leedom@chelsio.com>
To: <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-228.uvs.sntcca.sbcglobal.net ([99.65.72.228]:32577
	"EHLO stargate.chelsio.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932490AbaFSOzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 10:55:25 -0400
Content-Disposition: inline
In-Reply-To: <1403168810-9001-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 19, 2014 at 17:06:50 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> This lock is used in BH enabled condition and softirq context, so need to
> disable BH to avoid the dead lock:
> 	=================================
> 	[ INFO: inconsistent lock state ]
> 	3.14.7+ #24 Tainted: G         C O
> 	---------------------------------
> 	inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
> 	radvd/3794 [HC0[0]:SC1[1]:HE1:SE0] takes:
> 	 (adap_rcu_lock){+.?...}, at: [<ffffffffa09989ea>] clip_add+0x2c/0x116 [cxgb4]
> 	{SOFTIRQ-ON-W} state was registered at:
> 	  [<ffffffff810fca81>] __lock_acquire+0x34a/0xe48
> 	  [<ffffffff810fd98b>] lock_acquire+0x82/0x9d
> 	  [<ffffffff815d6ff8>] _raw_spin_lock+0x34/0x43
> 	  [<ffffffffa09989ea>] clip_add+0x2c/0x116 [cxgb4]
> 	  [<ffffffffa0998beb>] cxgb4_inet6addr_handler+0x117/0x12c [cxgb4]
> 	  [<ffffffff815da98b>] notifier_call_chain+0x32/0x5c
> 	  [<ffffffff815da9f9>] __atomic_notifier_call_chain+0x44/0x6e
> 	  [<ffffffff815daa32>] atomic_notifier_call_chain+0xf/0x11
> 	  [<ffffffff815b1356>] inet6addr_notifier_call_chain+0x16/0x18
> 	  [<ffffffffa01f72e5>] ipv6_add_addr+0x404/0x46e [ipv6]
> 	  [<ffffffffa01f8df0>] addrconf_add_linklocal+0x5f/0x95 [ipv6]
> 	  [<ffffffffa01fc3e9>] addrconf_notify+0x632/0x841 [ipv6]
> 	  [<ffffffff815da98b>] notifier_call_chain+0x32/0x5c
> 	  [<ffffffff810e09a1>] __raw_notifier_call_chain+0x9/0xb
> 	  [<ffffffff810e09b2>] raw_notifier_call_chain+0xf/0x11
> 	  [<ffffffff8151b3b7>] call_netdevice_notifiers_info+0x4e/0x56
> 	  [<ffffffff8151b3d0>] call_netdevice_notifiers+0x11/0x13
> 	  [<ffffffff8151c0a6>] netdev_state_change+0x1f/0x38
> 	  [<ffffffff8152f004>] linkwatch_do_dev+0x3b/0x49
> 	  [<ffffffff8152f184>] __linkwatch_run_queue+0x10b/0x144
> 	  [<ffffffff8152f1dd>] linkwatch_event+0x20/0x27
> 	  [<ffffffff810d7bc0>] process_one_work+0x1cb/0x2ee
> 	  [<ffffffff810d7e3b>] worker_thread+0x12e/0x1fc
> 	  [<ffffffff810dd391>] kthread+0xc4/0xcc
> 	  [<ffffffff815dc48c>] ret_from_fork+0x7c/0xb0
> 	irq event stamp: 3388
> 	hardirqs last  enabled at (3388): [<ffffffff810c6c85>] __local_bh_enable_ip+0xaa/0xd9
> 	hardirqs last disabled at (3387): [<ffffffff810c6c2d>] __local_bh_enable_ip+0x52/0xd9
> 	softirqs last  enabled at (3288): [<ffffffffa01f1d5b>] rcu_read_unlock_bh+0x0/0x2f [ipv6]
> 	softirqs last disabled at (3289): [<ffffffff815ddafc>] do_softirq_own_stack+0x1c/0x30
> 
> 	other info that might help us debug this:
> 	 Possible unsafe locking scenario:
> 
> 	       CPU0
> 	       ----
> 	  lock(adap_rcu_lock);
> 	  <Interrupt>
> 	    lock(adap_rcu_lock);
> 
> 	 *** DEADLOCK ***
> 
> Reported-by: Ben Greear <greearb@candelatech.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> Cc: Casey Leedom <leedom@chelsio.com>
> Cc: Hariprasad Shenai <hariprasad@chelsio.com>
> ---
Acked-by: Hariprasad Shenai <hariprasad@chelsio.com>

Thanks
