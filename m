From: Simon Kirby <sim@hostway.ca>
Subject: Re: Linux 3.1-rc9
Date: Mon, 31 Oct 2011 10:32:46 -0700
Message-ID: <20111031173246.GA10614@hostway.ca>
References: <1318874090.4172.84.camel@twins> <CA+55aFwCBy=4YK6amE=H-BYu9-boj4Po2Zkgf4V261mCx0DC4A@mail.gmail.com> <1318879396.4172.92.camel@twins> <alpine.LFD.2.02.1110172237030.3240@ionos> <alpine.LFD.2.02.1110181037120.3240@ionos> <1318928713.21167.4.camel@twins> <20111018182046.GF1309@hostway.ca> <alpine.LFD.2.02.1110182146440.3240@ionos> <20111024190203.GA24410@hostway.ca> <20111025202049.GB25043@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Network Development <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111025202049.GB25043@hostway.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 25, 2011 at 01:20:49PM -0700, Simon Kirby wrote:

> On Mon, Oct 24, 2011 at 12:02:03PM -0700, Simon Kirby wrote:
> 
> > Ok, hit the hang about 4 more times, but only this morning on a box with
> > a serial cable attached. Yay!
> 
> Here's lockdep output from another box. This one looks a bit different.

One more, again a bit different. The last few lockups have looked like
this. Not sure why, but we're hitting this at a few a day now. Thomas,
this is without your patch, but as you said, that's right before a free
and should print a separate lockdep warning.

No "huh" lines until after the trace on this one. I'll move to 3.1 with
cherry-picked b0691c8e now.

Simon-

[104661.173798] 
[104661.173801] =======================================================
[104661.179922] [ INFO: possible circular locking dependency detected ]
[104661.179922] 3.1.0-rc10-hw-lockdep+ #51
[104661.179922] -------------------------------------------------------
[104661.179922] watchdog.pl/29331 is trying to acquire lock:
[104661.179922]  (slock-AF_INET/1){+.-.-.}, at: [<ffffffff81664887>] tcp_v4_rcv+0x867/0xc10
[104661.179922] 
[104661.179922] but task is already holding lock:
[104661.179922]  (slock-AF_INET){+.-.-.}, at: [<ffffffff81604540>] sk_clone+0x120/0x420
[104661.179922] 
[104661.179922] which lock already depends on the new lock.
[104661.179922] 
[104661.179922] 
[104661.179922] the existing dependency chain (in reverse order) is:
[104661.239412] 
[104661.239412] -> #1 (slock-AF_INET){+.-.-.}:
[104661.244767]        [<ffffffff8109a7b9>] lock_acquire+0x109/0x140
[104661.244767]        [<ffffffff816f55fc>] _raw_spin_lock+0x3c/0x50
[104661.244767]        [<ffffffff81604540>] sk_clone+0x120/0x420
[104661.244767]        [<ffffffff8164cb33>] inet_csk_clone+0x13/0x90
[104661.244767]        [<ffffffff816669a5>] tcp_create_openreq_child+0x25/0x4d0
[104661.244767]        [<ffffffff81664c78>] tcp_v4_syn_recv_sock+0x48/0x2c0
[104661.244767]        [<ffffffff816667f5>] tcp_check_req+0x335/0x4c0
[104661.244767]        [<ffffffff81663e5e>] tcp_v4_do_rcv+0x29e/0x460
[104661.244767]        [<ffffffff816648ac>] tcp_v4_rcv+0x88c/0xc10   
[104661.244767]        [<ffffffff81641960>] ip_local_deliver_finish+0x100/0x2f0
[104661.244767]        [<ffffffff81641bdd>] ip_local_deliver+0x8d/0xa0
[104661.244767]        [<ffffffff81641203>] ip_rcv_finish+0x1a3/0x510 
[104661.244767]        [<ffffffff816417e2>] ip_rcv+0x272/0x2f0
[104661.244767]        [<ffffffff81610d67>] __netif_receive_skb+0x4d7/0x560
[104661.244767]        [<ffffffff81610ec0>] process_backlog+0xd0/0x1e0
[104661.244767]        [<ffffffff81613880>] net_rx_action+0x140/0x2c0 
[104661.244767]        [<ffffffff810640b8>] __do_softirq+0x138/0x250  
[104661.244767]        [<ffffffff817002bc>] call_softirq+0x1c/0x30    
[104661.244767]        [<ffffffff810153c5>] do_softirq+0x95/0xd0      
[104661.244767]        [<ffffffff81063dbd>] local_bh_enable_ip+0xed/0x110
[104661.244767]        [<ffffffff816f5e9f>] _raw_spin_unlock_bh+0x3f/0x50
[104661.244767]        [<ffffffff81602e41>] release_sock+0x161/0x1d0
[104661.244767]        [<ffffffff816762ed>] inet_stream_connect+0x6d/0x2f0
[104661.244767]        [<ffffffff815fcfeb>] kernel_connect+0xb/0x10
[104661.244767]        [<ffffffff816aaf86>] xs_tcp_setup_socket+0x2a6/0x4c0
[104661.244767]        [<ffffffff81078cf9>] process_one_work+0x1e9/0x560   
[104661.244767]        [<ffffffff81079403>] worker_thread+0x193/0x420      
[104661.244767]        [<ffffffff81080466>] kthread+0x96/0xb0
[104661.244767]        [<ffffffff817001c4>] kernel_thread_helper+0x4/0x10
[104661.244767] 
[104661.244767] -> #0 (slock-AF_INET/1){+.-.-.}:
[104661.244767]        [<ffffffff8109a000>] __lock_acquire+0x2040/0x2180
[104661.244767]        [<ffffffff8109a7b9>] lock_acquire+0x109/0x140
[104661.244767]        [<ffffffff816f55aa>] _raw_spin_lock_nested+0x3a/0x50
[104661.244767]        [<ffffffff81664887>] tcp_v4_rcv+0x867/0xc10
[104661.244767]        [<ffffffff81641960>] ip_local_deliver_finish+0x100/0x2f0
[104661.244767]        [<ffffffff81641bdd>] ip_local_deliver+0x8d/0xa0
[104661.244767]        [<ffffffff81641203>] ip_rcv_finish+0x1a3/0x510 
[104661.244767]        [<ffffffff816417e2>] ip_rcv+0x272/0x2f0
[104661.244767]        [<ffffffff81610d67>] __netif_receive_skb+0x4d7/0x560
[104661.244767]        [<ffffffff81612e24>] netif_receive_skb+0x104/0x120  
[104661.244767]        [<ffffffff81612f70>] napi_skb_finish+0x50/0x70
[104661.244767]        [<ffffffff81613635>] napi_gro_receive+0xc5/0xd0
[104661.244767]        [<ffffffffa000ad50>] bnx2_poll_work+0x610/0x1560 [bnx2]
[104661.244767]        [<ffffffffa000bde6>] bnx2_poll+0x66/0x250 [bnx2]
[104661.244767]        [<ffffffff81613880>] net_rx_action+0x140/0x2c0  
[104661.244767]        [<ffffffff810640b8>] __do_softirq+0x138/0x250   
[104661.244767]        [<ffffffff817002bc>] call_softirq+0x1c/0x30     
[104661.244767]        [<ffffffff810153c5>] do_softirq+0x95/0xd0       
[104661.244767]        [<ffffffff81063c8d>] irq_exit+0xdd/0x110        
[104661.244767]        [<ffffffff81014b74>] do_IRQ+0x64/0xe0           
[104661.244767]        [<ffffffff816f6273>] ret_from_intr+0x0/0x1a     
[104661.244767]        [<ffffffff816f65b5>] page_fault+0x25/0x30     
[104661.244767] 
[104661.244767] other info that might help us debug this:
[104661.244767] 
[104661.244767]  Possible unsafe locking scenario:
[104661.244767]        
[104661.244767]        CPU0                    CPU1
[104661.244767]        ----                    ----
[104661.244767]   lock(slock-AF_INET);
[104661.244767]                                lock(slock-AF_INET);
[104661.244767]                                lock(slock-AF_INET);
[104661.244767]   lock(slock-AF_INET);
[104661.244767] 
[104661.244767]  *** DEADLOCK ***
[104661.244767] 
[104661.244767] 3 locks held by watchdog.pl/29331:
[104661.244767]  #0:  (slock-AF_INET){+.-.-.}, at: [<ffffffff81604540>] sk_clone+0x120/0x420
[104661.244767]  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff816109f5>] __netif_receive_skb+0x165/0x560
[104661.244767]  #2:  (rcu_read_lock){.+.+..}, at: [<ffffffff816418a0>] ip_local_deliver_finish+0x40/0x2f0
[104661.244767] 
[104661.244767] stack backtrace:
[104661.244767] Pid: 29331, comm: watchdog.pl Not tainted 3.1.0-rc10-hw-lockdep+ #51
[104661.244767] Call Trace:
[104661.244767]  <IRQ>  [<ffffffff81097eab>] print_circular_bug+0x21b/0x330
[104661.244767]  [<ffffffff8109a000>] __lock_acquire+0x2040/0x2180
[104661.244767]  [<ffffffff8109a7b9>] lock_acquire+0x109/0x140
[104661.244767]  [<ffffffff81664887>] ? tcp_v4_rcv+0x867/0xc10
[104661.244767]  [<ffffffff816f55aa>] _raw_spin_lock_nested+0x3a/0x50
[104661.244767]  [<ffffffff81664887>] ? tcp_v4_rcv+0x867/0xc10
[104661.244767]  [<ffffffff81664887>] tcp_v4_rcv+0x867/0xc10  
[104661.244767]  [<ffffffff816418a0>] ? ip_local_deliver_finish+0x40/0x2f0
[104661.244767]  [<ffffffff81636978>] ? nf_hook_slow+0x148/0x1a0
[104661.244767]  [<ffffffff81641960>] ip_local_deliver_finish+0x100/0x2f0
[104661.244767]  [<ffffffff816418a0>] ? ip_local_deliver_finish+0x40/0x2f0
[104661.244767]  [<ffffffff81641bdd>] ip_local_deliver+0x8d/0xa0
[104661.244767]  [<ffffffff81641203>] ip_rcv_finish+0x1a3/0x510 
[104661.244767]  [<ffffffff816417e2>] ip_rcv+0x272/0x2f0
[104661.244767]  [<ffffffff81610d67>] __netif_receive_skb+0x4d7/0x560
[104661.244767]  [<ffffffff816109f5>] ? __netif_receive_skb+0x165/0x560
[104661.244767]  [<ffffffff81612e24>] netif_receive_skb+0x104/0x120
[104661.244767]  [<ffffffff81612d43>] ? netif_receive_skb+0x23/0x120
[104661.244767]  [<ffffffff816133ab>] ? dev_gro_receive+0x29b/0x380 
[104661.244767]  [<ffffffff816132a2>] ? dev_gro_receive+0x192/0x380 
[104661.244767]  [<ffffffff81612f70>] napi_skb_finish+0x50/0x70
[104661.244767]  [<ffffffff81613635>] napi_gro_receive+0xc5/0xd0
[104661.244767]  [<ffffffffa000ad50>] bnx2_poll_work+0x610/0x1560 [bnx2]
[104661.244767]  [<ffffffffa000bde6>] bnx2_poll+0x66/0x250 [bnx2]
[104661.244767]  [<ffffffff81613880>] net_rx_action+0x140/0x2c0  
[104661.244767]  [<ffffffff810640b8>] __do_softirq+0x138/0x250   
[104661.244767]  [<ffffffff817002bc>] call_softirq+0x1c/0x30     
[104661.244767]  [<ffffffff810153c5>] do_softirq+0x95/0xd0       
[104661.244767]  [<ffffffff81063c8d>] irq_exit+0xdd/0x110        
[104661.244767]  [<ffffffff81014b74>] do_IRQ+0x64/0xe0           
[104661.244767]  [<ffffffff816f6273>] common_interrupt+0x73/0x73
[104661.244767]  <EOI>  [<ffffffff816f99b3>] ? do_page_fault+0x93/0x520
[104661.244767]  [<ffffffff816f99af>] ? do_page_fault+0x8f/0x520
[104661.244767]  [<ffffffff81149afc>] ? vfsmount_lock_local_unlock+0x1c/0x40
[104661.244767]  [<ffffffff8114a79b>] ? mntput_no_expire+0x3b/0x150
[104661.244767]  [<ffffffff8114a8ca>] ? mntput+0x1a/0x30
[104661.244767]  [<ffffffff8112c540>] ? fput+0x190/0x230
[104661.244767]  [<ffffffff813a60ed>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[104661.244767]  [<ffffffff816f65b5>] page_fault+0x25/0x30
[104661.897577] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000101, exited with 00000102?
[104661.923653] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000101, exited with 00000102?
[104663.418206] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000101, exited with 00000102?
[104666.420003] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000101, exited with 00000102?
[104672.425159] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000101, exited with 00000102?
[104684.423542] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000102, exited with 00000103?
[104691.206752] huh, entered softirq 3 NET_RX ffffffff81613740 preempt_count 00000101, exited with 00000102?
