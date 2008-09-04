From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: BUG? locking issue(networking?) with latest git
Date: Fri, 5 Sep 2008 01:43:27 +0300
Message-ID: <200809050143.27998.denys@visp.net.lb>
References: <20080904072155.GA4691@ff.dom.local> <200809041714.05578.denys@visp.net.lb> <20080904214839.GA2834@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:59123 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754722AbYIDWow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 18:44:52 -0400
In-Reply-To: <20080904214839.GA2834@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I catch it!!!! And it is not ppp seems.

On router where no changes on interfaces done, and there is 
heavy traffic passing. No ppp interfaces. No parallel tc commands, 
just one this, it is even not batch, just many tc commands, one by one.

Once i had similar issue on this router, but because of obsolete git 
snapshot i didn't report.

Here is command that stuck. ifconfig, tc doesn't work, and seems 
even sockets cannot be created (i cannot open new ssh connection 
from this router, but i can ssh to existing socket).

I trigger this bug on latest git too.


  PID  PPID USER     STAT   VSZ %MEM %CPU COMMAND
11593     1 root     R     2048  0.1 47.5 tc qdisc del dev ifb0 root
 3494     1 root     D     5832  0.2  0.0 /usr/sbin/snmpd -c /config/snmpd.conf
 3474     1 squid    S     2852  0.1  0.0 /usr/sbin/ripd -d
 3467     1 root     D     2608  0.1  0.0 /usr/sbin/zebra -d
    1     0 root     S     2376  0.1  0.0 /bin/sh /init

Sep  5 00:54:13 Router-Dora syslog.info syslogd exiting
Sep  5 00:54:47 Router-Dora syslog.info syslogd started: BusyBox v1.11.1
Sep  5 00:54:49 Router-Dora user.info kernel: 1123
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f73a5eb8 00000082 00000020 00000700 f66e7600 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f7c36f40 f7c37094 c201b280 00000001 00000013 f788e540 f7d6e800 f7c37094 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        fffc3f06 00000013 ffffffff 00000000 f7e52846 000000b8 00000020 00000000 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aa758>] schedule_timeout+0x16/0x9d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c013240c>] ? up+0x2b/0x2f
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f254>] ? add_wait_queue+0x2f/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c020c1a1>] read_chan+0x379/0x5ab
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c020be28>] ? read_chan+0x0/0x5ab
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0209956>] tty_read+0x5f/0x96
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02098f7>] ? tty_read+0x0/0x96
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015db90>] vfs_read+0x83/0xed
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015dc93>] sys_read+0x3b/0x60
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] ash           S 00000296     0  4384   1123
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f6ddef34 00000082 f6c68dbc 00000296 000000d0 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f7c37960 f7c37ab4 c201b280 00000001 00000018 f7c84c40 c011825e f7c37ab4 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        00002c20 c20112e0 433829cb c0369330 f7c357a0 00000000 f7c37960 00000000 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011825e>] ? __enqueue_entity+0xe3/0xeb
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0121b78>] do_wait+0x1ac/0x282
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0121ccc>] sys_wait4+0x7e/0x94
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0121cf5>] sys_waitpid+0x13/0x15
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] ssh           S c201b758     0  5078   4188
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f4e06b4c 00000082 f2569b00 c201b758 ed0b5320 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f25686c0 f2568814 c201b280 00000001 ef784cb4 f7f8ec40 c037399c f2568814 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f4e06b2c c0126ffe f4e06b3c f4e06b54 f4e06b54 00000286 f4e06b4c c0127162 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126ffe>] ? lock_timer_base+0x1f/0x3e
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0127162>] ? __mod_timer+0x90/0x9b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aa7c1>] schedule_timeout+0x7f/0x9d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126cd4>] ? process_timeout+0x0/0xa
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0167e22>] do_select+0x449/0x4bb
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c016845f>] ? __pollwait+0x0/0xb5
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c025fa09>] ? __qdisc_run+0xc0/0x183
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02532d2>] ? dev_queue_xmit+0x41f/0x453
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270960>] ? ip_finish_output+0x1ce/0x206
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270a16>] ? ip_output+0x7e/0x83
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c026fd4d>] ? ip_local_out+0x18/0x1b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270460>] ? ip_queue_xmit+0x289/0x2ca
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0123602>] ? irq_exit+0x53/0x6d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0105ef6>] ? do_IRQ+0xae/0xc4
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010421b>] ? common_interrupt+0x23/0x28
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126ffe>] ? lock_timer_base+0x1f/0x3e
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0127162>] ? __mod_timer+0x90/0x9b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c01271d6>] ? mod_timer+0x21/0x27
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024ada1>] ? sk_reset_timer+0xf/0x1a
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015a7f2>] ? kfree+0x83/0x8f
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024dbb2>] ? __kfree_skb+0x63/0x66
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015a938>] ? kmem_cache_free+0x66/0x72
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024dbb2>] ? __kfree_skb+0x63/0x66
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aba7d>] ? _spin_unlock_bh+0xd/0xf
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024a9f7>] ? release_sock+0x7f/0x87
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0275e75>] ? tcp_recvmsg+0x83f/0x91b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0168047>] core_sys_select+0x1b3/0x246
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024828a>] ? sock_aio_read+0xec/0xfa
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015d33b>] ? do_sync_read+0xab/0xe9
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0141189>] ? handle_fasteoi_irq+0x0/0xad
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0123602>] ? irq_exit+0x53/0x6d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0105ef6>] ? do_IRQ+0xae/0xc4
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010421b>] ? common_interrupt+0x23/0x28
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c016839f>] sys_select+0x88/0x148
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0141189>] ? handle_fasteoi_irq+0x0/0xad
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0123602>] ? irq_exit+0x53/0x6d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] sshd          S c0843000     0  5419   4171
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f17a2b4c 00000082 f17a2af8 c0843000 c0141189 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f7c35b00 f7c35c54 c201b280 00000001 f17a2bdc f788fa40 f17a2b54 f7c35c54 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f17a2b2c c0126ffe f17a2b3c f17a2b54 f17a2b54 00000286 f17a2b4c c0127162 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0141189>] ? handle_fasteoi_irq+0x0/0xad
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126ffe>] ? lock_timer_base+0x1f/0x3e
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0127162>] ? __mod_timer+0x90/0x9b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aa7c1>] schedule_timeout+0x7f/0x9d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126cd4>] ? process_timeout+0x0/0xa
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0167e22>] do_select+0x449/0x4bb
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c016845f>] ? __pollwait+0x0/0xb5
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02532d2>] ? dev_queue_xmit+0x41f/0x453
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270960>] ? ip_finish_output+0x1ce/0x206
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270a16>] ? ip_output+0x7e/0x83
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c026fd4d>] ? ip_local_out+0x18/0x1b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270460>] ? ip_queue_xmit+0x289/0x2ca
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024c3a1>] ? __skb_clone+0x22/0xde
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c027e96e>] ? tcp_transmit_skb+0x546/0x57d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024ef69>] ? memcpy_toiovec+0x2c/0x50
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024dbb2>] ? __kfree_skb+0x63/0x66
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015a938>] ? kmem_cache_free+0x66/0x72
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024dbb2>] ? __kfree_skb+0x63/0x66
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aba7d>] ? _spin_unlock_bh+0xd/0xf
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024a9f7>] ? release_sock+0x7f/0x87
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0275e75>] ? tcp_recvmsg+0x83f/0x91b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0168047>] core_sys_select+0x1b3/0x246
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024828a>] ? sock_aio_read+0xec/0xfa
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015d33b>] ? do_sync_read+0xab/0xe9
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c016839f>] sys_select+0x88/0x148
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] ash           S 00000296     0  5420   5419
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f17b2f34 00000082 f17b44c0 00000296 000000d0 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f7c350e0 f7c35234 c201b280 00000001 00000018 f788ec40 c011825e f7c35234 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        c20112bc c20112e0 072289af c0369330 f7c361c0 00000000 f7c350e0 f17b2f78 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011825e>] ? __enqueue_entity+0xe3/0xeb
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0121a96>] ? do_wait+0xca/0x282
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0121b78>] do_wait+0x1ac/0x282
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0121ccc>] sys_wait4+0x7e/0x94
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0121cf5>] sys_waitpid+0x13/0x15
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] sh            S 00000400     0  5421   5420
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f17b6e50 00000082 c011ad56 00000400 f7c361c0 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f7c361c0 f7c36314 c201b280 00000001 c011b454 f7f8ea80 c201b280 f7c36314 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        000008f1 f72341f8 00000001 f17b6e2c c011b469 f17b6e50 c01178ab 00000000 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011ad56>] ? check_preempt_wakeup+0x10a/0x112
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b454>] ? try_to_wake_
Sep  5 00:54:49 Router-Dora user.info kernel: up+0x165/0x16f
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b469>] ? default_wake_function+0xb/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c01178ab>] ? __wake_up_common+0x35/0x5b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0162942>] pipe_wait+0x51/0x71
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0163009>] pipe_read+0x29e/0x2fd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015d33b>] do_sync_read+0xab/0xe9
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015d290>] ? do_sync_read+0x0/0xe9
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015db90>] vfs_read+0x83/0xed
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015dc93>] sys_read+0x3b/0x60
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] mpstat        S 00000049     0  5461   4384
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f0f47fa8 00000086 c020e71c 00000049 f7868800 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f7c357a0 f7c358f4 c2011280 00000000 00000002 f79548c0 00000049 f7c358f4 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        20ad4224 00000000 00000000 f751b528 bfc83764 f6b1eb00 fffffff7 00000000 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c020e71c>] ? tty_ldisc_deref+0x5c/0x63
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c01276fa>] sys_pause+0x14/0x1b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] sshd          S c2011758     0 11554   4171
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f2717b4c 00000086 c0369330 c2011758 f37c1708 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f7c92520 f7c92674 c2011280 00000000 ee5e0234 f260efc0 c036a780 f7c92674 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        20acb824 c0126ffe f2717b3c f2717b54 f2717b54 00000286 f2717b4c 00000000 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126ffe>] ? lock_timer_base+0x1f/0x3e
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aa7c1>] schedule_timeout+0x7f/0x9d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126cd4>] ? process_timeout+0x0/0xa
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0167e22>] do_select+0x449/0x4bb
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c016845f>] ? __pollwait+0x0/0xb5
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0267cd3>] ? nf_hook_slow+0x38/0x8e
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270960>] ? ip_finish_output+0x1ce/0x206
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270a16>] ? ip_output+0x7e/0x83
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c026fd4d>] ? ip_local_out+0x18/0x1b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270460>] ? ip_queue_xmit+0x289/0x2ca
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0141189>] ? handle_fasteoi_irq+0x0/0xad
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0105ef6>] ? do_IRQ+0xae/0xc4
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010421b>] ? common_interrupt+0x23/0x28
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0281dc3>] ? tcp_v4_send_check+0x7d/0xb7
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126ffe>] ? lock_timer_base+0x1f/0x3e
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0127162>] ? __mod_timer+0x90/0x9b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c01271d6>] ? mod_timer+0x21/0x27
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024ada1>] ? sk_reset_timer+0xf/0x1a
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c027e31f>] ? tcp_event_new_data_sent+0x8a/0x8e
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0280d98>] ? __tcp_push_pending_frames+0x6a8/0x790
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024e489>] ? __alloc_skb+0x49/0xf8
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aba7d>] ? _spin_unlock_bh+0xd/0xf
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024a9f7>] ? release_sock+0x7f/0x87
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0276b0b>] ? tcp_sendmsg+0x7d4/0x8c5
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b469>] ? default_wake_function+0xb/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0168047>] core_sys_select+0x1b3/0x246
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0248191>] ? sock_aio_write+0xe8/0xf5
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015d252>] ? do_sync_write+0xab/0xe9
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c016839f>] sys_select+0x88/0x148
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] ash           S 00000296     0 11555  11554
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f1a2cf34 00000082 c012cfa5 00000296 000000d0 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f7c932a0 f7c933f4 c201b280 00000001 000009c4 f260f180 c011825e f7c933f4 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        c20112bc c20112e0 9d614929 c0369330 f7c921c0 00000000 f7c932a0 f1a2cf78 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012cfa5>] ? alloc_pid+0x19/0x2c3
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011825e>] ? __enqueue_entity+0xe3/0xeb
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0121a96>] ? do_wait+0xca/0x282
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0121b78>] do_wait+0x1ac/0x282
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0121ccc>] sys_wait4+0x7e/0x94
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0121cf5>] sys_waitpid+0x13/0x15
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] sh            S 00000400     0 11556  11555
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f4627e50 00000082 c011ad56 00000400 f7c921c0 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f7c921c0 f7c92314 c2011280 00000000 c011b454 f52ee540 c2011280 f7c92314 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        20a822e8 eceb59f8 00000001 f4627e2c c011b469 f4627e50 c01178ab 00000000 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011ad56>] ? check_preempt_wakeup+0x10a/0x112
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b454>] ? try_to_wake_up+0x165/0x16f
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b469>] ? default_wake_function+0xb/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c01178ab>] ? __wake_up_common+0x35/0x5b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0162942>] pipe_wait+0x51/0x71
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0163009>] pipe_read+0x29e/0x2fd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015d33b>] do_sync_read+0xab/0xe9
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015d290>] ? do_sync_read+0x0/0xe9
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015db90>] vfs_read+0x83/0xed
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015dc93>] sys_read+0x3b/0x60
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] sshd          S c201b758     0 11590   4171
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        effa0b4c 00000086 00000003 c201b758 eea334b0 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f79521c0 f7952314 c201b280 00000001 ed2e7734 f260f500 c037399c f7952314 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        effa0b2c c0126ffe effa0b3c effa0b54 effa0b54 00000286 effa0b4c c0127162 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126ffe>] ? lock_timer_base+0x1f/0x3e
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0127162>] ? __mod_timer+0x90/0x9b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aa7c1>] schedule_timeout+0x7f/0x9d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126cd4>] ? process_timeout+0x0/0xa
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0167e22>] do_select+0x449/0x4bb
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012376b>] ? local_bh_enable+0x71/0x7d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c016845f>] ? __pollwait+0x0/0xb5
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02532d2>] ? dev_queue_xmit+0x41f/0x453
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270960>] ? ip_finish_output+0x1ce/0x206
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270a16>] ? ip_output+0x7e/0x83
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c026fd4d>] ? ip_local_out+0x18/0x1b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270460>] ? ip_queue_xmit+0x289/0x2ca
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0123602>] ? irq_exit+0x53/0x6d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126ffe>] ? lock_timer_base+0x1f/0x3e
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0127162>] ? __mod_timer+0x90/0x9b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c01271d6>] ? mod_timer+0x21/0x27
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024ada1>] ? sk_reset_timer+0xf/0x1a
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c027e31f>] ? tcp_event_new_data_sent+0x8a/0x8e
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0280d98>] ? __tcp_push_pending_frames+0x6a8/0x790
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024e489>] ? __alloc_skb+0x49/0xf8
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aba7d>] ? _spin_unlock_bh+0xd/0xf
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024a9f7>] ? release_sock+0x7f/0x87
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0276b0b>] ? tcp_sendmsg+0x7d4/0x8c5
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0168047>] core_sys_select+0x1b3/0x246
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0248191>] ? sock_aio_write+0xe8/0xf5
Sep  5 00:54:49 Router-Dora user.warn kernel: 
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074]  [<c015d252>] ? do_sync_write+0xab/0xe9
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c020be28>] ? read_chan+0x0/0x5ab
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c016839f>] sys_select+0x88/0x148
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] ash           R running      0 11591  11590
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        c011fc4e 00000000 ffff8000 00000009 f2814e8e c0866ba3 00000010 f2814ebc 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        0000205d f2814e8e 00000004 00000092 00000000 6d66d1f0 0000001a 355b0004 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        31363834 00000011 f2814e8b f7951440 f2814ea0 c02a9da9 c0327c97 f2814eac 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012d64d>] ? __kernel_text_address+0x34/0x3e
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0104a10>] ? dump_trace+0xb1/0xe5
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0104920>] ? print_trace_address+0x0/0x3f
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0104ad3>] show_stack_log_lvl+0x8f/0xa7
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0105849>] show_stack+0x25/0x2f
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011c969>] sched_show_task+0x89/0x93
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011c9af>] show_state_filter+0x3c/0x71
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02186cc>] sysrq_handle_showstate+0xa/0xc
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c021861b>] __handle_sysrq+0x9b/0x112
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c018baef>] ? write_sysrq_trigger+0x0/0x2d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c018bb15>] write_sysrq_trigger+0x26/0x2d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c01869db>] proc_reg_write+0x58/0x6c
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0186983>] ? proc_reg_write+0x0/0x6c
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015d9e5>] vfs_write+0x86/0xf0
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015dae8>] sys_write+0x3b/0x60
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] tc            R running      0 11593      1
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        00000060 00000202 f79521c0 00000046 00000046 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f2569b00 f2569c58 c201b280 00000001 c0105ef6 00000000 c0382a00 f2569c54 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        ee848038 f5857000 ed33ac24 c010421b ee848038 00000000 f787ac80 ee848038 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0105ef6>] ? do_IRQ+0xae/0xc4
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010421b>] ? common_interrupt+0x23/0x28
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011d566>] ? sys_sched_yield+0x2e/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aa72d>] ? yield+0x12/0x14
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c025f6c0>] ? dev_deactivate+0x138/0x149
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0260b3c>] ? qdisc_graft+0x65/0x1b5
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0260da6>] ? tc_get_qdisc+0x11a/0x149
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0260c8c>] ? tc_get_qdisc+0x0/0x149
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c025af35>] ? rtnetlink_rcv_msg+0x196/0x1b0
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c025ad9f>] ? rtnetlink_rcv_msg+0x0/0x1b0
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c026669b>] ? netlink_rcv_skb+0x30/0x75
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c025ad97>] ? rtnetlink_rcv+0x1c/0x24
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0266238>] ? netlink_unicast+0x1a3/0x204
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02664b8>] ? netlink_sendmsg+0x21f/0x22c
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0248f53>] ? sock_sendmsg+0xca/0xe1
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024efcd>] ? verify_iovec+0x40/0x6f
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02490a9>] ? sys_sendmsg+0x13f/0x192
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02498a8>] ? sys_recvmsg+0x116/0x17b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024977b>] ? move_addr_to_user+0x3b/0x52
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0249aa2>] ? sys_getsockname+0x52/0x6f
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aba7d>] ? _spin_unlock_bh+0xd/0xf
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024a9f7>] ? release_sock+0x7f/0x87
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024bf2f>] ? sock_setsockopt+0x4e9/0x4f3
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0249e90>] ? sys_socketcall+0x14b/0x17f
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] ? sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] sshd          S c0382a00     0 11594   4171
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        ecf18b4c 00000082 f2569b00 c0382a00 ecf18c28 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f7953600 f7953754 c201b280 00000001 c0843000 f260fa40 c037399c f7953754 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        ecf18b2c c0126ffe ecf18b3c ecf18b54 ecf18b54 00000286 ecf18b4c c0127162 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126ffe>] ? lock_timer_base+0x1f/0x3e
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0127162>] ? __mod_timer+0x90/0x9b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aa7c1>] schedule_timeout+0x7f/0x9d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126cd4>] ? process_timeout+0x0/0xa
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0167e22>] do_select+0x449/0x4bb
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c016845f>] ? __pollwait+0x0/0xb5
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270960>] ? ip_finish_output+0x1ce/0x206
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270a16>] ? ip_output+0x7e/0x83
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c026fd4d>] ? ip_local_out+0x18/0x1b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270460>] ? ip_queue_xmit+0x289/0x2ca
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270a16>] ? ip_output+0x7e/0x83
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c026fd4d>] ? ip_local_out+0x18/0x1b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0281dc3>] ? tcp_v4_send_check+0x7d/0xb7
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c027e96e>] ? tcp_transmit_skb+0x546/0x57d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015a3c7>] ? __slab_alloc+0x97/0x43f
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c027e041>] ? tcp_init_tso_segs+0x2d/0x3d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0280af3>] ? __tcp_push_pending_frames+0x403/0x790
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c027df9a>] ? tcp_current_mss+0x6d/0xe7
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024aa8c>] ? lock_sock_nested+0x8d/0x95
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aba7d>] ? _spin_unlock_bh+0xd/0xf
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024a9f7>] ? release_sock+0x7f/0x87
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0276b0b>] ? tcp_sendmsg+0x7d4/0x8c5
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0168047>] core_sys_select+0x1b3/0x246
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0248191>] ? sock_aio_write+0xe8/0xf5
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015d252>] ? do_sync_write+0xab/0xe9
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c020be28>] ? read_chan+0x0/0x5ab
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c016839f>] sys_select+0x88/0x148
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] ash           S b7eaf000     0 11595  11594
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f7dc8eb8 00000086 000002af b7eaf000 ecf1cb00 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f79517a0 f79518f4 c2011280 00000000 00000000 f52eefc0 ecf1cb00 f79518f4 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        20a8681c f7dc8fb0 f7dc8fb0 c0113279 00000007 f7dc8fb8 f52eeff4 00000000 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0113279>] ? do_page_fault+0x2c5/0x5fc
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aa758>] schedule_timeout+0x16/0x9d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f254>] ? add_wait_queue+0x2f/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c020c1a1>] read_chan+0x379/0x5ab
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c020be28>] ? read_chan+0x0/0x5ab
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0209956>] tty_read+0x5f/0x96
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02098f7>] ? tty_read+0x0/0x96
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015db90>] vfs_read+0x83/0xed
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015dc93>] sys_read+0x3b/0x60
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] sshd          S c201b758     0 11606   4171
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f07b0b4c 00000086 00000003 c201b758 ef50dc80 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f7951b00 f7951c54 c201b280 00000001 f782ae34 f260fc00 c037399c f7951c54 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f07b0b2c c0126ffe f07b0b3c f07b0b54 f07b0b54 00000286 f07b0b4c c0127162 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126ffe>] ? lock_timer_base+0x1f/0x3e
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0127162>] ? __mod_timer+0x90/0x9b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aa7c1>] schedule_timeout+0x7f/0x9d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126cd4>] ? process_timeout+0x0/0xa
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0167e22>] do_select+0x449/0x4bb
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c016845f>] ? __pollwait+0x0/0xb5
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b4
Sep  5 00:54:49 Router-Dora user.info kernel: 5e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02532d2>] ? dev_queue_xmit+0x41f/0x453
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270960>] ? ip_finish_output+0x1ce/0x206
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270a16>] ? ip_output+0x7e/0x83
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c026fd4d>] ? ip_local_out+0x18/0x1b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270460>] ? ip_queue_xmit+0x289/0x2ca
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c026fd4d>] ? ip_local_out+0x18/0x1b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0270460>] ? ip_queue_xmit+0x289/0x2ca
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126ffe>] ? lock_timer_base+0x1f/0x3e
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0127162>] ? __mod_timer+0x90/0x9b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c01271d6>] ? mod_timer+0x21/0x27
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024ada1>] ? sk_reset_timer+0xf/0x1a
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c027e31f>] ? tcp_event_new_data_sent+0x8a/0x8e
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0280d98>] ? __tcp_push_pending_frames+0x6a8/0x790
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024e489>] ? __alloc_skb+0x49/0xf8
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aba7d>] ? _spin_unlock_bh+0xd/0xf
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024a9f7>] ? release_sock+0x7f/0x87
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0276b0b>] ? tcp_sendmsg+0x7d4/0x8c5
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0168047>] core_sys_select+0x1b3/0x246
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0248191>] ? sock_aio_write+0xe8/0xf5
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015d252>] ? do_sync_write+0xab/0xe9
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c020be28>] ? read_chan+0x0/0x5ab
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c016839f>] sys_select+0x88/0x148
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] ash           S ed617ed0     0 11607  11606
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        ed617f34 00000086 c0141189 ed617ed0 c0123602 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f7c34d80 f7c34ed4 c2011280 00000000 f2568db4 f52ef500 c011810e f7c34ed4 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        20aaea40 f2568dac f2568d80 c2011280 f2568d80 00000000 f7c34d80 00000000 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0141189>] ? handle_fasteoi_irq+0x0/0xad
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0123602>] ? irq_exit+0x53/0x6d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011810e>] ? __dequeue_entity+0x73/0x7b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0121b78>] do_wait+0x1ac/0x282
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0121ccc>] sys_wait4+0x7e/0x94
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0121cf5>] sys_waitpid+0x13/0x15
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] ping          S f7d40700     0 11613  11607
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f0fedcc4 00000082 c0369330 f7d40700 ecfba000 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f2568d80 f2568ed4 c2011280 00000000 f70a48a0 f52eea80 f0fedca8 f2568ed4 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        20ad4024 c0126ffe f0fedcb4 f0fedccc f0fedccc 00000286 f0fedcc4 00000000 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126ffe>] ? lock_timer_base+0x1f/0x3e
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aa7c1>] schedule_timeout+0x7f/0x9d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0126cd4>] ? process_timeout+0x0/0xa
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024f9a7>] __skb_recv_datagram+0x189/0x1e5
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024fa23>] skb_recv_datagram+0x20/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02853fb>] raw_recvmsg+0x60/0x12a
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024a115>] sock_common_recvmsg+0x31/0x4a
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0248e34>] sock_recvmsg+0xd1/0xe9
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024efcd>] ? verify_iovec+0x40/0x6f
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024987a>] sys_recvmsg+0xe8/0x17b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c020df02>] ? tty_mode_ioctl+0x170/0x26c
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0117f63>] ? __wake_up+0x31/0x3b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0141189>] ? handle_fasteoi_irq+0x0/0xad
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0123602>] ? irq_exit+0x53/0x6d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0105ef6>] ? do_IRQ+0xae/0xc4
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010421b>] ? common_interrupt+0x23/0x28
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0249e9f>] sys_socketcall+0x15a/0x17f
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] scp           T c200da74     0 11617  11591
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f67fde8c 00000082 00000000 c200da74 00000400 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f2568360 f25684b4 c2011280 00000000 c015a938 f52ef180 00000046 f25684b4 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f7c9e120 f7c9e14c f67fdf30 f67fde6c c0127b5a 00000014 f67fde84 f2568600 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015a938>] ? kmem_cache_free+0x66/0x72
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0127b5a>] ? __sigqueue_free+0x2d/0x30
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012959d>] do_signal_stop+0xdf/0x12a
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0129d59>] get_signal_to_deliver+0x229/0x304
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0102bf0>] do_notify_resume+0x6b/0x6e4
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0121ba0>] ? do_wait+0x1d4/0x282
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c011b45e>] ? default_wake_function+0x0/0xd
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0121cd5>] ? sys_wait4+0x87/0x94
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0121cf5>] ? sys_waitpid+0x13/0x15
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0103946>] work_notifysig+0x13/0x19
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] dbclient      D 00000000     0 11618  11617
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f6cffd38 00000082 00000000 00000000 00000000 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f256af40 f256b094 c2011280 00000000 00000000 f7955a40 00000000 f256b094 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        20ab46c4 00000400 00000000 00000000 00000000 00000000 00000078 00000000 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aab9d>] __mutex_lock_slowpath+0x56/0x83
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aaa54>] mutex_lock+0xd/0xf
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c025ad8b>] rtnetlink_rcv+0x10/0x24
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0266238>] netlink_unicast+0x1a3/0x204
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02664b8>] netlink_sendmsg+0x21f/0x22c
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0248f53>] sock_sendmsg+0xca/0xe1
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0147cb9>] ? __alloc_pages_internal+0x96/0x364
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0154488>] ? page_add_new_anon_rmap+0x42/0x45
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c014f230>] ? handle_mm_fault+0x18d/0x683
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0117f63>] ? __wake_up+0x31/0x3b
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02491a0>] sys_sendto+0xa4/0xc3
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024977b>] ? move_addr_to_user+0x3b/0x52
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0249aa2>] ? sys_getsockname+0x52/0x6f
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0180992>] ? inotify_d_instantiate+0x12/0x34
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0248c68>] ? sock_attach_fd+0x7f/0xac
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0249e1f>] sys_socketcall+0xda/0x17f
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:49 Router-Dora user.info kernel: [548610.893074] syslogd       S ef6ddd30     0 11627      1
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        ef6ddd84 00000086 c1f6e584 ef6ddd30 00000000 c0831fa8 c0835280 c0835280 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        f256a1c0 f256a314 c2011280 00000000 00000038 f52ee8c0 ecaf4ec4 f256a314 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]        20ad3824 00000000 c1f6e580 ecaf4e18 ef6ddd74 c0175244 00000049 00000000 
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074] Call Trace:
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0175244>] ? simple_write_end+0xaf/0xc1
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c02aa758>] schedule_timeout+0x16/0x9d
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f169>] ? prepare_to_wait_exclusive+0x4f/0x55
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024f9a7>] __skb_recv_datagram+0x189/0x1e5
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024fa23>] skb_recv_datagram+0x20/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0299cc9>] unix_dgram_recvmsg+0x56/0x207
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c01448fa>] ? __generic_file_aio_write_nolock+0x3c7/0x3ff
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c024828a>] sock_aio_read+0xec/0xfa
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015d33b>] do_sync_read+0xab/0xe9
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c0169922>] ? vfs_lock_file+0x2d/0x31
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c016913b>] ? locks_free_lock+0x3d/0x40
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015dba1>] vfs_read+0x94/0xed
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c015dc93>] sys_read+0x3b/0x60
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:54:49 Router-Dora user.warn kernel: [548610.893074]  =======================
Sep  5 00:54:52 Router-Dora user.info kernel: [548613.052034] SysRq : Show Pending Timers
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] Timer List Version: v0.3
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] HRTIMER_MAX_CLOCK_BASES: 2
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] now at 548613052168541 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] 
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] cpu: 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  clock 0:
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .index:      0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .resolution: 999848 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .get_time:   ktime_get_real
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .offset:     0 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] active timers:
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  clock 1:
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .index:      1
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .resolution: 999848 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .get_time:   ktime_get
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .offset:     0 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] active timers:
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  #0: <f2814ed4>, it_real_fn, S:01
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  # expires at 548613364078994 nsecs [in 311910453 nsecs]
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .expires_next   : 634247169024 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .hres_active    : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .nr_events      : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .nohz_mode      : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_tick      : 0 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .tick_stopped   : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_jiffies   : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_calls     : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_sleeps    : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_entrytime : 548613051813608 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_waketime  : 0 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_exittime  : 0 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_sleeptime : 350141963668130 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .last_jiffies   : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .next_jiffies   : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_expires   : 0 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] jiffies: 548227807
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] 
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] cpu: 1
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  clock 0:
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .index:      0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .resolution: 999848 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .get_time:   ktime_get_real
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .offset:     0 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] active timers:
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  clock 1:
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .index:      1
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .resolution: 999848 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .get_time:   ktime_get
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .offset:     0 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] active timers:
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .expires_next   : 4694678033408 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .hres_active    : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .nr_events      : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .nohz_mode      : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_tick      : 0 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .tick_stopped   : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_jiffies   : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_calls     : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_sleeps    : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_entrytime : 548280602620624 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_waketime  : 0 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_exittime  : 0 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_sleeptime : 228138217362087 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .last_jiffies   : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .next_jiffies   : 0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]   .idle_expires   : 0 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] jiffies: 548227807
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] 
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] 
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] Tick Device: mode:     0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] Clock Event Device: hpet
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  max_delta_ns:   2147483647
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  min_delta_ns:   3352
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  mult:           61496114
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  shift:          32
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  mode:           2
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  next_event:     0 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  set_next_event: hpet_legacy_next_event
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  set_mode:       hpet_legacy_set_mode
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  event_handler:  tick_handle_periodic_broadcast
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] tick_broadcast_mask: 00000003
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] tick_broadcast_oneshot_mask: 00000000
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] 
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] 
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] Tick Device: mode:     0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] Clock Event Device: lapic
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  max_delta_ns:   672906762
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  min_delta_ns:   1203
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  mult:           53542028
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  shift:          32
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  mode:           1
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  next_event:     634247169024 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  set_next_event: lapic_next_event
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  set_mode:       lapic_timer_setup
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  event_handler:  tick_handle_periodic
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] 
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] Tick Device: mode:     0
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] Clock Event Device: lapic
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  max_delta_ns:   672906762
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  min_delta_ns:   1203
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  mult:           53542028
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  shift:          32
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  mode:           1
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  next_event:     4694678033408 nsecs
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  set_next_event: lapic_next_event
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  set_mode:       lapic_timer_setup
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047]  event_handler:  tick_handle_periodic
Sep  5 00:54:52 Router-Dora user.warn kernel: [548613.052047] 
Sep  5 00:55:07 Router-Dora user.info kernel: [548628.403167] SysRq : Show Blocked State
Sep  5 00:55:07 Router-Dora user.info kernel: [548628.403296]   task                PC stack   pid father
Sep  5 00:55:07 Router-Dora user.info kernel: [548628.403306] zebra         D f7e80cd0     0  3467      1
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403309]        f7e80ce0 00000086 f5db93c0 f7e80cd0 c010421b c0831fa8 c0835280 c0835280 
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403315]        f7c34360 f7c344b4 c201b280 00000001 00000024 f7c856c0 c0265383 f7c344b4 
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403319]        00000000 f7e80cd0 c026628d ffffefff f78a0200 0000005c 00000000 ffffefff 
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403324] Call Trace:
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403327]  [<c010421b>] ? common_interrupt+0x23/0x28
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403333]  [<c0265383>] ? netlink_sendskb+0x1c/0x34
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403338]  [<c026628d>] ? netlink_unicast+0x1f8/0x204
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403341]  [<c02aab9d>] __mutex_lock_slowpath+0x56/0x83
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403346]  [<c02aaa54>] mutex_lock+0xd/0xf
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403349]  [<c025ad8b>] rtnetlink_rcv+0x10/0x24
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403354]  [<c0266238>] netlink_unicast+0x1a3/0x204
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403357]  [<c02664b8>] netlink_sendmsg+0x21f/0x22c
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403360]  [<c0248f53>] sock_sendmsg+0xca/0xe1
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403363]  [<c024ef69>] ? memcpy_toiovec+0x2c/0x50
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403368]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403372]  [<c0275e75>] ? tcp_recvmsg+0x83f/0x91b
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403376]  [<c024efcd>] ? verify_iovec+0x40/0x6f
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403379]  [<c02490a9>] sys_sendmsg+0x13f/0x192
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403383]  [<c0141189>] ? handle_fasteoi_irq+0x0/0xad
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403387]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403390]  [<c0128490>] ? lock_task_sighand+0x2d/0x4e
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403394]  [<c012a324>] ? getrusage+0x199/0x1ab
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403398]  [<c0249e90>] sys_socketcall+0x14b/0x17f
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403401]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403405]  =======================
Sep  5 00:55:07 Router-Dora user.info kernel: [548628.403407] snmpd         D f7424018     0  3494      1
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403410]        f7f69e84 00200086 edc4e00c f7424018 00000000 c0831fa8 c0835280 c0835280 
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403414]        f7c91440 f7c91594 c2011280 00000000 bfbbe048 f7f8efc0 00000050 f7c91594 
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403419]        20a83a08 00000000 00000000 00000000 0811e908 f7f69e90 f7f69e78 00000000 
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403424] Call Trace:
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403426]  [<c02aab9d>] __mutex_lock_slowpath+0x56/0x83
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403429]  [<c02aaa54>] mutex_lock+0xd/0xf
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403432]  [<c025ad79>] rtnl_lock+0xd/0xf
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403435]  [<c025416e>] dev_ioctl+0x22/0x5df
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403438]  [<c024b2b5>] ? sk_prot_alloc+0x15/0x65
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403441]  [<c0180992>] ? inotify_d_instantiate+0x12/0x34
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403446]  [<c028675b>] ? udp_ioctl+0x0/0x62
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403451]  [<c0248824>] sock_ioctl+0x1e5/0x1f1
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403454]  [<c024863f>] ? sock_ioctl+0x0/0x1f1
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403457]  [<c0166c4a>] vfs_ioctl+0x22/0x69
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403460]  [<c0166ebd>] do_vfs_ioctl+0x22c/0x23f
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403463]  [<c0249680>] ? sys_socket+0x43/0x5a
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403466]  [<c0166efc>] sys_ioctl+0x2c/0x48
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403469]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403472]  =======================
Sep  5 00:55:07 Router-Dora user.info kernel: [548628.403478] dbclient      D 00000000     0 11618  11617
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403480]        f6cffd38 00000082 00000000 00000000 00000000 c0831fa8 c0835280 c0835280 
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403485]        f256af40 f256b094 c2011280 00000000 00000000 f7955a40 00000000 f256b094 
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403489]        20ab46c4 00000400 00000000 00000000 00000000 00000000 00000078 00000000 
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403494] Call Trace:
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403496]  [<c02aab9d>] __mutex_lock_slowpath+0x56/0x83
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403499]  [<c02aaa54>] mutex_lock+0xd/0xf
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403502]  [<c025ad8b>] rtnetlink_rcv+0x10/0x24
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403505]  [<c0266238>] netlink_unicast+0x1a3/0x204
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403508]  [<c02664b8>] netlink_sendmsg+0x21f/0x22c
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403511]  [<c0248f53>] sock_sendmsg+0xca/0xe1
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403514]  [<c0147cb9>] ? __alloc_pages_internal+0x96/0x364
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403518]  [<c012f05b>] ? autoremove_wake_function+0x0/0x33
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403521]  [<c0154488>] ? page_add_new_anon_rmap+0x42/0x45
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403525]  [<c014f230>] ? handle_mm_fault+0x18d/0x683
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403530]  [<c0117f63>] ? __wake_up+0x31/0x3b
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403535]  [<c02491a0>] sys_sendto+0xa4/0xc3
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403538]  [<c024977b>] ? move_addr_to_user+0x3b/0x52
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403541]  [<c0249aa2>] ? sys_getsockname+0x52/0x6f
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403544]  [<c0180992>] ? inotify_d_instantiate+0x12/0x34
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403547]  [<c0248c68>] ? sock_attach_fd+0x7f/0xac
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403551]  [<c0249e1f>] sys_socketcall+0xda/0x17f
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403554]  [<c010384d>] sysenter_do_call+0x12/0x25
Sep  5 00:55:07 Router-Dora user.warn kernel: [548628.403557]  =======================
Sep  5 00:55:30 Router-Dora user.info kernel: [548651.313906] device net_disable_timestamp()
Sep  5 00:55:33 Router-Dora authpriv.info dropbear[11606]: exit after auth (root): error reading: Connection reset by peer

==============================================================
===============================
===============================


and latest git i can trigger bug too (after running shaper scripts 5-6 times)
Lockdep enabled, and not showing anything.

Mem: 174936K used, 1880544K free, 0K shrd, 1184K buff, 36644K cached
CPU:  0.0% usr 32.1% sys  0.0% nice 31.2% idle  0.0% io  0.0% irq 36.5% softirq
Load average: 2.07 0.82 0.31
  PID  PPID USER     STAT   VSZ %MEM %CPU COMMAND
 4465  4436 root     R     2044  0.1 49.9 tc qdisc del dev eth1.3 root
    7     2 root     SW<      0  0.0  6.5 [ksoftirqd/1]
 2856     1 squid    S     2720  0.1  0.4 /usr/sbin/ripd -d
 4468  4467 root     R     2376  0.1  0.1 top
 4466  3234 root     S     2232  0.1  0.1 /usr/sbin/sshd -b /etc/banner
 2878     1 root     D     5832  0.2  0.0 /usr/sbin/snmpd -c /config/snmpd.conf
 2849     1 root     D     2608  0.1  0.0 /usr/sbin/zebra -d
    1     0 root     S     2376  0.1  0.0 /bin/sh /init
 3334  3333 root     S     2376  0.1  0.0 -ash
 3250  1114 root     S     2376  0.1  0.0 /sbin/getty 38400 tty1
 3251  1114 root     S     2376  0.1  0.0 /sbin/getty 38400 tty2
 3254  1114 root     S     2376  0.1  0.0 /sbin/getty 38400 tty3
 4436  3334 root     S     2376  0.1  0.0 sh qos_visp.cfg
 4467  4466 root     S     2376  0.1  0.0 -ash


Sep  5 01:20:09 Router-Dora syslog.info syslogd started: BusyBox v1.11.1
Sep  5 01:20:15 Router-Dora user.info kernel: [  246.974440] SysRq : Show State
Sep  5 01:20:15 Router-Dora user.info kernel: [  246.974587]   task                PC stack   pid father
Sep  5 01:20:15 Router-Dora user.info kernel: [  246.974597] init          S c013b0fe     0     1      0
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974602]        f7819f34 00000046 f7819ecc c013b0fe c0a467d0 c097bf5c c097f280 c097f280
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974610]        f7830000 f7830154 c2d46280 00000000 f7830000 f72a0000 f7830390 f7830154
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974617]        c013b11a f7830000 c03a1990 c01233ca f7819f28 00000246 00000001 00000246
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974624] Call Trace:
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974627]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974640]  [<c013b11a>] ? lock_release_holdtime+0x1a/0x153
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974644]  [<c01233ca>] ? do_wait+0x188/0x285
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974652]  [<c01233f1>] do_wait+0x1af/0x285
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974656]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974660]  [<c0123545>] sys_wait4+0x7e/0x94
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974664]  [<c012356e>] sys_waitpid+0x13/0x15
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974667]  [<c01038b9>] sysenter_do_call+0x12/0x35
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974672]  =======================
Sep  5 01:20:15 Router-Dora user.info kernel: [  246.974674] kthreadd      S c01085d7     0     2      0
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974678]        f781afc0 00000046 f781af64 c01085d7 c0a46a70 c097bf5c c097f280 c097f280
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974685]        f7830b80 f7830cd4 c2d46280 00000000 f7830b80 f72a4d80 f7830f10 f7830cd4
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974692]        fffc1ae1 f7830b80 c0389de4 c0130f65 f781afb4 00000246 00000001 00000000
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974699] Call Trace:
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974700]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974706]  [<c0130f65>] ? kthreadd+0x142/0x147
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974712]  [<c0130e8e>] kthreadd+0x6b/0x147
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974715]  [<c0130e23>] ? kthreadd+<kee===0  097[33:_r 24t6.97i6.9t6.g 24>>[e<c0x04e89=of b0b cl13xd
Sep  5 01:20:15 Router-Dora user.info kernel: 2  24c4>[ 1/
Sep  5 01:20:15 Router-Dora user.warn kernel: 424603045a7]=ch 0ff8  fltr6.9c  [c]  e<c
Sep  5 01:20:15 Router-Dora user.info kernel:  ker==    e3a1>lo[<co0]  +870]  [<c0d  [<a7b1
Sep  5 01:20:15 Router-Dora user.warn kernel: thread+040/7_h<==s<  4]ffc0 f 4]fcfc 0 <4__do_/e60>] c70]q[<cq0130f1? k7lper=748S>[c94 f8 70x1cc[  >6.9d0130f6a>] 073>r====285 
007280683e80003783r7>] 8e6c] r]  [<r74k870m246.o4871? k.ad.<6>
Sep  5 01:20:15 Router-Dora user.warn kernel: 8300f37303<4 8c 7707d_0s_ s_<]9 0aa==elp    8c06 cf<4>[  2  8fb484_c8s_4ard6ead8ke_2_th.b/0<[  k  2=bockd bfc0 c072800870f7bf>24n 201/0
[xb/0x54>46a3
Sep  5 01:20:15 Router-Dora user.info kernel: 24[  ]70] x57<===b5   0100]  ec017e8c69748]ck7dx>]>pr4dc 41_x  0]  5c  a3d7<4>86 f<  218b/7dir0xc>]bf>4uto046>]20x3]
Sep  5 01:20:15 Router-Dora user.warn kernel: ]er+0x7/0x4==a747846
Sep  5 01:20:15 Router-Dora user.info kernel:  0  2]x331<4>f97x573<==d  2 5d8   23ce71e.972_sc2har[c r4ead9_w/5>e> kt4+0x050
Sep  5 01:20:15 Router-Dora user.warn kernel: =0] 0870]8f2807e77
Sep  5 01:20:15 Router-Dora user.info kernel: 080 c0199>a+ce+01x>] ?80x07e040006d789>246.?
Sep  5 01:20:15 Router-Dora user.info kernel:  c47804>4at>ac1] <wa7/01/03+0 nct734/c  24ac6>0==4 >007
Sep  5 01:20:15 Router-Dora user.info kernel:  00 1    f25f>246dd
Sep  5 01:20:15 Router-Dora user.info kernel: c0xe9ir4ai[c3
Sep  5 01:20:15 Router-Dora user.info kernel:
Sep  5 01:20:15 Router-Dora user.info kernel: ?.9x1/3>
Sep  5 01:20:15 Router-Dora user.info kernel: ==0 40dcfd0x>] ?ece8+12e/1>]c  [<c0r] x]
Sep  5 01:20:15 Router-Dora user.info kernel:  kee===   S c0    0 c 45e<r6.ead+4_wa[ker ad.x00/07[ p  472430
Sep  5 01:20:15 Router-Dora user.info kernel: ]28b 707]x338 [u]<43 2467
Sep  5 01:20:15 Router-Dora user.info kernel: =97b48 5c6 c26.a296f80:
Sep  5 01:20:15 Router-Dora user.info kernel: c/0x<b/0cler7hres mtx0]d  [427e246k]  [/3>]7=5d79>01303>0re ac7000739 c011246c]
Sep  5 01:20:15 Router-Dora user.info kernel:  ? k<c0e46h [_ero0ouag>] 0] ?3>]l4> 870 70]e24=  80c5 _246   2c 24e48i24k70]74870]_6.97=b-s   497bf a3de<47fe 9] 7qs8d_ rel2_ti0on _h r_c f  
e07d7f28 .974s6.]
Sep  5 01:20:15 Router-Dora user.info kernel: ef
Sep  5 01:20:15 Router-Dora user.info kernel: 0b/0x]3 lr+ >[?0]_   00246  80  000c0]  d7 4748e748v.9k  2c6. x10c/0xdb<4>4xd
Sep  5 01:20:15 Router-Dora user.info kernel: 0tibl re>x ?[_st/870x]
Sep  5 01:20:15 Router-Dora user.info kernel: ern =]10 010f77[2cf>]
Sep  5 01:20:15 Router-Dora user.info kernel:  a0>] ? worc kt ad+6ead<==k
Sep  5 01:20:15 Router-Dora user.emerg kernel:  f0  8d
Sep  5 01:20:15 Router-Dora user.info kernel: ? tr+013c_01314] w4uto[orke9/0x6]870e  =>c010>00024>[f73bf0082bc82974e0]a 2  2 [  03
Sep  5 01:20:15 Router-Dora user.info kernel:  _f6/0xc3
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0130fa5>] kthread+0x3b/0x61
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0130f6a>] ? kthread+0x0/0x61
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0104573>] kernel_thread_helper+0x7/0x10
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:15 Router-Dora user.info kernel: [  246.974870] kjournald     S c01085d7     0  1109      2
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        f7955f8c 00000046 f7955f30 c01085d7 00000003 c097bf5c c097f280 c097f280
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        f72f0000 f72f0154 c2d46280 00000000 f72f0000 f72a2400 f72f0390 f72f0154
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        c013b11a f72f0000 f72fa824 c01aebef f7955f80 00000246 00000001 00000246
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b11a>] ? lock_release_holdtime+0x1a/0x153
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01aebef>] ? kjournald+0x16b/0x1e3
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01aebf4>] kjournald+0x170/0x1e3
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0131211>] ? autoremove_wake_function+0x0/0x33
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01aea84>] ? kjournald+0x0/0x1e3
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0130fa5>] kthread+0x3b/0x61
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0130f6a>] ? kthread+0x0/0x61
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0104573>] kernel_thread_helper+0x7/0x10
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:15 Router-Dora user.info kernel: [  246.974870] linuxrc       S c013b0fe     0  1114      1
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        f7317f4c 00000046 f7317ee4 c013b0fe c0a467d0 c097bf5c c097f280 c097f280
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        f72f5080 f72f51d4 c2e70280 00000001 f72f5080 f72a5d40 f72f5410 f72f51d4
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        fffc1e83 f72f5080 c03a1990 c01233ca f7317f40 00000246 00000001 00000000
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01233ca>] ? do_wait+0x188/0x285
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01233f1>] do_wait+0x1af/0x285
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0123545>] sys_wait4+0x7e/0x94
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01038b9>] sysenter_do_call+0x12/0x35
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:15 Router-Dora user.info kernel: [  246.974870] loop0         S c01085d7     0  1147      2
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        f79c5f60 00000046 f79c5f04 c01085d7 f72f2280 c097bf5c c097f280 c097f280
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        f72f2280 f72f23d4 c2d46280 00000000 f79c5fbc f72a4d80 c013ce60 f72f23d4
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        fffc1ae1 f79c5f34 c013ce8c f79c5f44 00000246 f79c5fb0 f72ef364 00000000
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce60>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<f896f5a8>] loop_thread+0xb1/0x3b4 [loop]
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce60>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0131211>] ? autoremove_wake_function+0x0/0x33
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<f896f4f7>] ? loop_thread+0x0/0x3b4 [loop]
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0130fa5>] kthread+0x3b/0x61
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0130f6a>] ? kthread+0x0/0x61
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0104573>] kernel_thread_helper+0x7/0x10
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:15 Router-Dora user.info kernel: [  246.974870] klogd         R running      0  2160      1
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        f6d06f40 c01debce f6d06f5c c01e24a7 82c20f60 00000001 c0388394 c0388384
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        00000000 f6d06f6c c02be4ed 00000034 000006dd f6d06fa8 c0121c8c 00002000
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        080bd980 f6d06fb0 c025979d f7275c00 c01def60 00000001 f6d06fa0 c013ce60
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01debce>] ? __delay+0x9/0xb
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01e24a7>] _raw_spin_lock+0xa7/0x118
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c02be4f4>] _spin_lock_irq+0x4a/0x51
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0121c8c>] do_syslog+0x13e/0x2f8
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c025979d>] ? sys_socketcall+0xc5/0x180
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01def60>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce60>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0121e57>] sys_syslog+0x11/0x16
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01038b9>] sysenter_do_call+0x12/0x35
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:15 Router-Dora user.info kernel: [  246.974870] zebra         D 00000086     0  2849      1
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        f6d49cd0 00000046 00000001 00000086 00000000 c097bf5c c097f280 c097f280
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        f7272280 f72723d4 c2e70280 00000001 c0398228 f72a5b00 00000046 f72723d4
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        fffe7248 f7272280 00000000 f6d49cb8 c013cce9 f7272280 c013ce8c 00000000
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013cce9>] ? mark_held_locks+0x53/0x6a
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c02bcfd8>] mutex_lock_nested+0x13c/0x21e
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c026af97>] ? rtnetlink_rcv+0x12/0x26
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c026af97>] rtnetlink_rcv+0x12/0x26
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c02767f2>] netlink_unicast+0x1a9/0x20a
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0276a75>] netlink_sendmsg+0x222/0x22f
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c025889d>] sock_sendmsg+0xca/0xe1
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0131211>] ? autoremove_wake_function+0x0/0x33
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b
Sep  5 01:20:15 Router-Dora user.info kernel: 11a>] ? lock_release_holdtime+0x1a/0x153
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c017328e>] ? core_sys_select+0x2c/0x2cb
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01df407>] ? copy_from_user+0x34/0x11b
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01df407>] ? copy_from_user+0x34/0x11b
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c025ed04>] ? verify_iovec+0x40/0x70
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c02589f3>] sys_sendmsg+0x13f/0x192
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013efd2>] ? lock_release_non_nested+0x187/0x1db
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c012a088>] ? lock_task_sighand+0x47/0x80
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c012a0a3>] ? lock_task_sighand+0x62/0x80
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b11a>] ? lock_release_holdtime+0x1a/0x153
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce60>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01df524>] ? copy_to_user+0x36/0x106
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c012c0a4>] ? getrusage+0x199/0x1ab
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0259823>] sys_socketcall+0x14b/0x180
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01def60>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01038b9>] sysenter_do_call+0x12/0x35
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:15 Router-Dora user.info kernel: [  246.974870] ripd          S f7272e00     0  2856      1
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        f6d5ab48 00000046 c01085d7 f7272e00 f783a010 c097bf5c c097f280 c097f280
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        f7272e00 f7272f54 c2e70280 00000001 f6d5ab10 f72a6400 f783a000 f7272f54
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        ffff2e90 c013ce8c f6d5ab28 00000286 f6d5ab50 f783a000 f6d5ab48 00000000
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c02bc8a7>] schedule_timeout+0x7f/0x9d
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01287ff>] ? process_timeout+0x0/0xa
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01731ff>] do_select+0x48e/0x4f1
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01738b2>] ? __pollwait+0x0/0xb6
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013cce9>] ? mark_held_locks+0x53/0x6a
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce60>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c025a3c7>] ? release_sock+0xac/0xb4
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0125161>] ? local_bh_enable_ip+0xa6/0xaa
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c02be298>] ? _spin_unlock_bh+0x25/0x28
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013db62>] ? __lock_acquire+0x5bd/0x11aa
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c025877e>] ? sock_recvmsg+0xd1/0xe9
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b11a>] ? lock_release_holdtime+0x1a/0x153
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c017328e>] ? core_sys_select+0x2c/0x2cb
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0173451>] core_sys_select+0x1ef/0x2cb
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013efd2>] ? lock_release_non_nested+0x187/0x1db
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c012a088>] ? lock_task_sighand+0x47/0x80
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c012a0a3>] ? lock_task_sighand+0x62/0x80
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b11a>] ? lock_release_holdtime+0x1a/0x153
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce60>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01df524>] ? copy_to_user+0x36/0x106
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01737f2>] sys_select+0x88/0x148
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01def60>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01038b9>] sysenter_do_call+0x12/0x35
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:15 Router-Dora user.info kernel: [  246.974870] snmpd         D f68a2e10     0  2878      1
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        f68a2e74 00200046 00000001 f68a2e10 c013b0fe c097bf5c c097f280 c097f280
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        f72f4500 f72f4654 c2d46280 00000000 f68a2e34 f72a7180 00200046 f72f4654
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        00000000 f72f4500 00000000 f68a2e5c c013cce9 f72f4500 c013ce8c 00200246
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013cce9>] ? mark_held_locks+0x53/0x6a
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce60>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c02bcfd8>] mutex_lock_nested+0x13c/0x21e
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c026af83>] ? rtnl_lock+0xf/0x11
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c026af83>] rtnl_lock+0xf/0x11
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0264637>] dev_ioctl+0x22/0x5e8
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c02579cb>] ? sock_destroy_inode+0x10/0x12
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce60>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0176320>] ? d_free+0x3b/0x4d
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0297962>] ? udp_ioctl+0x0/0x6e
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0258162>] sock_ioctl+0x1ee/0x1fa
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0257f74>] ? sock_ioctl+0x0/0x1fa
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0171fca>] vfs_ioctl+0x22/0x69
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0172243>] do_vfs_ioctl+0x232/0x245
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01691d7>] ? fput+0x17/0x19
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01def60>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0172282>] sys_ioctl+0x2c/0x46
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01038b9>] sysenter_do_call+0x12/0x35
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:15 Router-Dora user.info kernel: [  246.974870] sshd          S f744f72c     0  3234      1
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        f6f58b48 00000046 f6c3c500 f744f72c f6c3c890 c097bf5c c097f280 c097f280
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        f6c3c500 f6c3c654 c2e70280 00000001 c013ce60 f72a0900 00000246 f6c3c654
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]        fffe9749 f6f58b24 00000246 f6f58bec f744f71c f6f58b38 c01313d3 00000000
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c013ce60>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c01313d3>] ? add_wait_queue+0x2b/0x30
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c02bc83e>] schedule_timeout+0x16/0x9d
Sep  5 01:20:15 Router-Dora user.warn kernel: [  246.974870]  [<c0284f78>] ? tcp_poll+0x1b/0x128
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01731ff>] do_select+0x48e/0x4f1
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01738b2>] ? __pollwait+0x0/0xb6
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b11a>] ? lock_release_holdtime+0x1a/0x153
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013db62>] ? __lock_acquire+0x5bd/0x11aa
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013cce9>] ? mark_held_locks+0x53/0x6a
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01def60>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce60>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01def60>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013db62>] ? __lock_acquire+0x5bd/0x11aa
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013db62>] ? __lock_acquire+0x5bd/0x11aa
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b11a>] ? lock_release_holdtime+0x1a/0x153
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c017328e>] ? core_sy
Sep  5 01:20:16 Router-Dora user.info kernel: s_select+0x2c/0x2cb
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0173451>] core_sys_select+0x1ef/0x2cb
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01142c5>] ? do_page_fault+0x2e5/0x624
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0134441>] ? up_read+0x16/0x29
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01142c5>] ? do_page_fault+0x2e5/0x624
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce60>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce60>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0176320>] ? d_free+0x3b/0x4d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0176320>] ? d_free+0x3b/0x4d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c017b6ff>] ? mntput_no_expire+0x1a/0xe7
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01737f2>] sys_select+0x88/0x148
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01691d7>] ? fput+0x17/0x19
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01def60>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0113fe0>] ? do_page_fault+0x0/0x624
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce60>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01038b9>] sysenter_do_call+0x12/0x35
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:16 Router-Dora user.info kernel: [  246.974870] mactelnetd    S f6c39700     0  3243      1
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f657cb48 00000046 c01085d7 f6c39700 c09b1d10 c097bf5c c097f280 c097f280
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f6c39700 f6c39854 c2d46280 00000000 f657cb10 f72a0d80 c09b1d00 f6c39854
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f657cb18 c013ce8c f657cb28 00000286 f657cb50 c09b1d00 f657cb48 c0128cf6
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0128cf6>] ? __mod_timer+0x95/0xa0
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c02bc8a7>] schedule_timeout+0x7f/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01287ff>] ? process_timeout+0x0/0xa
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01731ff>] do_select+0x48e/0x4f1
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01738b2>] ? __pollwait+0x0/0xb6
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b11a>] ? lock_release_holdtime+0x1a/0x153
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c017328e>] ? core_sys_select+0x2c/0x2cb
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0173451>] core_sys_select+0x1ef/0x2cb
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01142c5>] ? do_page_fault+0x2e5/0x624
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0134441>] ? up_read+0x16/0x29
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01142c5>] ? do_page_fault+0x2e5/0x624
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c02be298>] ? _spin_unlock_bh+0x25/0x28
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c025a3c7>] ? release_sock+0xac/0xb4
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c029e5a3>] ? inet_bind+0x189/0x192
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0106193>] ? do_softirq+0xa3/0xb4
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0106193>] ? do_softirq+0xa3/0xb4
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c014a469>] ? handle_fasteoi_irq+0x0/0xb6
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01def60>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce60>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01def60>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0103980>] ? restore_nocheck_notrace+0x0/0xe
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01737f2>] sys_select+0x88/0x148
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01def60>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01038b9>] sysenter_do_call+0x12/0x35
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:16 Router-Dora user.info kernel: [  246.974870] getty         S f7972e5c     0  3250   1114
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f7972eb8 00000046 00000000 f7972e5c c013c47c c097bf5c c097f280 c097f280
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f7276780 f72768d4 c2e70280 00000001 f7972e78 f72a4240 f7972e8c f72768d4
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        fffc1e83 00000000 f7276780 00000000 f7972ea4 c013cce9 f7276780 00000000
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013c47c>] ? check_usage_backwards+0x54/0x76
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013cce9>] ? mark_held_locks+0x53/0x6a
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c02bc83e>] schedule_timeout+0x16/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01313d3>] ? add_wait_queue+0x2b/0x30
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c021b07d>] read_chan+0x384/0x5bc
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c021acf9>] ? read_chan+0x0/0x5bc
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c02186a6>] tty_read+0x65/0x9c
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0218641>] ? tty_read+0x0/0x9c
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0168b15>] vfs_read+0x83/0xed
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0168c18>] sys_read+0x3b/0x60
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01038b9>] sysenter_do_call+0x12/0x35
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:16 Router-Dora user.info kernel: [  246.974870] getty         S c0a5a810     0  3251   1114
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f724ceb8 00000046 00000000 c0a5a810 c0c0f9f0 c097bf5c c097f280 c097f280
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f7271700 f7271854 c2d46280 00000000 f724ce78 f72a06c0 f724ce8c f7271854
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        fffc1fb9 00000000 f7271700 00000000 f724cea4 c013cce9 f7271700 00000000
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013cce9>] ? mark_held_locks+0x53/0x6a
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c02bc83e>] schedule_timeout+0x16/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01313d3>] ? add_wait_queue+0x2b/0x30
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c021b07d>] read_chan+0x384/0x5bc
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c021acf9>] ? read_chan+0x0/0x5bc
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c02186a6>] tty_read+0x65/0x9c
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0218641>] ? tty_read+0x0/0x9c
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0168b15>] vfs_read+0x83/0xed
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0168c18>] sys_read+0x3b/0x60
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01038b9>] sysenter_do_call+0x12/0x35
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:16 Router-Dora user.info kernel: [  246.974870] getty         S c0a5a810     0  3254   1114
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f73aeeb8 00000046 00000000 c0a5a810 c0c0f9f0 c097bf5c c097f280 c097f280
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f7270000 f7270154 c2e70280 00000001 f73aee78 f72a4fc0 f73aee8c f7270154
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        fffc1e83 00000000 f7270000 00000000 f73aeea4 c013cce9 f7270000 00000000
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013cce9>] ? mark_held_locks+0x53/0x6a
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c02bc83e>] schedule_timeout+0x16/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01313d3>] ? add_wait_queue+0x2b/0x30
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c021b07d>] read_chan+0x384/0x5bc
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c021acf9>] ? read_chan+0x0/0x5bc
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c02186a6>] tty_read+0x65/0x9c
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0218641>] ? tty_read+0x0/0x9c
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0168b15>] vfs_read+0x83/0xed
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0168c18>] sys_read+0x3b/0x60
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01038b9>] sysenter_do_call+0x12/0x35
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:16 Router-Dora user.info kernel: [  246.974870] sshd          S f6c3a280     0  3333   3234
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f0eb1b48 00000046 c01085d7 f6c3a280 f783a010 c097bf5c c097f280 c097f280
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f6c3a280 f6c3a3d4 c2e70280 00000001 f0eb1b10 f72a3cc0 f783a000 f6c3a3d4
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        fffe8efd c013ce8c f0eb1b28 00000286 f0eb1b50 f783a000 f0eb1b48 00000000
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>]
Sep  5 01:20:16 Router-Dora user.info kernel:  ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c02bc8a7>] schedule_timeout+0x7f/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01287ff>] ? process_timeout+0x0/0xa
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01731ff>] do_select+0x48e/0x4f1
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01738b2>] ? __pollwait+0x0/0xb6
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c028170b>] ? ip_output+0x7e/0x83
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0280a24>] ? ip_local_out+0x18/0x1b
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c028114f>] ? ip_queue_xmit+0x289/0x2ca
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013db62>] ? __lock_acquire+0x5bd/0x11aa
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c025a3c7>] ? release_sock+0xac/0xb4
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0125161>] ? local_bh_enable_ip+0xa6/0xaa
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b11a>] ? lock_release_holdtime+0x1a/0x153
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c017328e>] ? core_sys_select+0x2c/0x2cb
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0173451>] core_sys_select+0x1ef/0x2cb
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0257ab8>] ? sock_aio_write+0xeb/0xf8
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01681d7>] ? do_sync_write+0xab/0xe9
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b11a>] ? lock_release_holdtime+0x1a/0x153
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c021acf9>] ? read_chan+0x0/0x5bc
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0131211>] ? autoremove_wake_function+0x0/0x33
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01737f2>] sys_select+0x88/0x148
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01def60>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01038b9>] sysenter_do_call+0x12/0x35
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:16 Router-Dora user.info kernel: [  246.974870] ash           S c013b0fe     0  3334   3333
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f08cdf34 00000046 f08cdecc c013b0fe c0a467d0 c097bf5c c097f280 c097f280
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f6c3ae00 f6c3af54 c2d46280 00000000 f6c3ae00 f72a2640 f6c3b190 f6c3af54
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        fffe65d1 f6c3ae00 c03a1990 c01233ca f08cdf28 00000246 00000001 00000000
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01233ca>] ? do_wait+0x188/0x285
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01233f1>] do_wait+0x1af/0x285
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0123545>] sys_wait4+0x7e/0x94
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c012356e>] sys_waitpid+0x13/0x15
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01038b9>] sysenter_do_call+0x12/0x35
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:16 Router-Dora user.info kernel: [  246.974870] sh            S c013b0fe     0  4436   3334
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        efc90f34 00000046 efc90ecc c013b0fe c0a467d0 c097bf5c c097f280 c097f280
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f6c3d080 f6c3d1d4 c2d46280 00000000 f6c3d080 f72a2f40 f6c3d410 f6c3d1d4
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        fffe68c6 f6c3d080 c03a1990 c01233ca efc90f28 00000246 00000001 00000000
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01233ca>] ? do_wait+0x188/0x285
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01233f1>] do_wait+0x1af/0x285
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0123545>] sys_wait4+0x7e/0x94
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c012356e>] sys_waitpid+0x13/0x15
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01038b9>] sysenter_do_call+0x12/0x35
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:16 Router-Dora user.info kernel: [  246.974870] tc            R running      0  4465   4436
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        efc49c10 00000046 00000001 00000000 c0a437b0 c097bf5c c097f280 c097f280
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f6c3dc00 f6c3dd58 c2d46280 00000000 c013b0fe f72a2400 c01085d7 f6c3dd54
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        c2d46290 f6c3dfb8 efc49bf4 c013b11a f6c3dc00 c2d46290 c011ea20 efc49c10
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b11a>] ? lock_release_holdtime+0x1a/0x153
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011ea20>] ? sys_sched_yield+0x0/0x50
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011ea6b>] sys_sched_yield+0x4b/0x50
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c02bc813>] yield+0x12/0x14
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c026fb67>] dev_deactivate+0x141/0x152
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0270fff>] qdisc_graft+0x65/0x188
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c027123c>] tc_get_qdisc+0x11a/0x149
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0271122>] ? tc_get_qdisc+0x0/0x149
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c026b143>] rtnetlink_rcv_msg+0x198/0x1b2
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c026afab>] ? rtnetlink_rcv_msg+0x0/0x1b2
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0276c5b>] netlink_rcv_skb+0x30/0x75
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c026afa3>] rtnetlink_rcv+0x1e/0x26
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c02767f2>] netlink_unicast+0x1a9/0x20a
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0276a75>] netlink_sendmsg+0x222/0x22f
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c025889d>] sock_sendmsg+0xca/0xe1
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0131211>] ? autoremove_wake_function+0x0/0x33
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0131211>] ? autoremove_wake_function+0x0/0x33
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01df407>] ? copy_from_user+0x34/0x11b
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01df407>] ? copy_from_user+0x34/0x11b
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c025ed04>] ? verify_iovec+0x40/0x70
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c02589f3>] sys_sendmsg+0x13f/0x192
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c025923b>] ? sys_recvmsg+0x116/0x17b
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0137a58>] ? clocksource_get_next+0x3c/0x43
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011eb0e>] ? scheduler_tick+0x9e/0x188
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0259823>] sys_socketcall+0x14b/0x180
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01def60>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01038b9>] sysenter_do_call+0x12/0x35
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:16 Router-Dora user.info kernel: [  246.974870] sshd          S f7273980     0  4466   3234
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f6e9eb48 00000046 c01085d7 f7273980 f783a010 c097bf5c c097f280 c097f280
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f7273980 f7273ad4 c2e70280 00000001 f6e9eb10 f72a5680 f783a000 f7273ad4
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f6e9eb18 c013ce8c f6e9eb28 00000286 f6e9eb50 f783a000 f6e9eb48 c0128cf6
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0128cf6>] ? __mod_timer+0x95/0xa0
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c02bc8a7>] schedule_timeout+0x7f/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01287ff>] ? process_timeout+0x0/0xa
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01731ff>] do_select+0x48e/0x4f1
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01738b2>] ? __pollwait+0x0/0xb6
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c011c742>] ? default_wake_function+0x0/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c028170b>] ? ip_output+0x7e/0x83
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0280a24>] ? ip_local_out+0x18/0x1b
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c028114f>] ? ip_queue_xmit+0x289/0x2ca
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013db62>] ? __lock_acquire+0x5bd/0x11aa
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c025a3c7>] ? release_sock+0xac/0xb4
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0125161>] ? local_bh_enable_ip+0xa6/0xaa
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b11a>] ? lock_release_holdtime+0x1a/0x153
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c017328e>] ? core_sys_select+0x2c/0x2cb
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0173451>] core_sys_select+0x1ef/0x2cb
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0257ab8>] ? s
Sep  5 01:20:16 Router-Dora user.info kernel: ock_aio_write+0xeb/0xf8
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01681d7>] ? do_sync_write+0xab/0xe9
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b11a>] ? lock_release_holdtime+0x1a/0x153
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c021acf9>] ? read_chan+0x0/0x5bc
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0131211>] ? autoremove_wake_function+0x0/0x33
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01737f2>] sys_select+0x88/0x148
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01def60>] ? trace_hardirqs_on_thunk+0xc/0x10
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01038b9>] sysenter_do_call+0x12/0x35
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:16 Router-Dora user.info kernel: [  246.974870] ash           R running      0  4467   4466
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        00000002 f780e540 c0197c72 f5642f50 c0197c98 fffffffb f5642f74 c01926b2
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f5642f9c 00000002 b7e3e000 f4baec00 f4baec00 c0192652 00000002 f5642f90
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        c016896a f5642f9c b7e3e000 f4baec00 fffffff7 b7e3e000 f5642fb0 c0168a6d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0197c72>] ? write_sysrq_trigger+0x0/0x2d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0197c98>] ? write_sysrq_trigger+0x26/0x2d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01926b2>] ? proc_reg_write+0x60/0x74
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0192652>] ? proc_reg_write+0x0/0x74
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c016896a>] ? vfs_write+0x86/0xf0
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0168a6d>] ? sys_write+0x3b/0x60
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01038b9>] ? sysenter_do_call+0x12/0x35
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  =======================
Sep  5 01:20:16 Router-Dora user.info kernel: [  246.974870] syslogd       S f79bcaac     0  4471      1
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        eff64d84 00000046 00000000 f79bcaac f7274500 c097bf5c c097f280 c097f280
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f7274500 f7274654 c2d46280 00000000 eff64d50 f72a5f80 00000003 f7274654
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]        f7274500 00000000 eff64d68 c013cce9 f7274500 c013ce8c eff64de4 eff64d78
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870] Call Trace:
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013cce9>] ? mark_held_locks+0x53/0x6a
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce8c>] ? trace_hardirqs_on+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce60>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c02bc83e>] schedule_timeout+0x16/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013131d>] ? prepare_to_wait_exclusive+0x4d/0x54
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c025f724>] __skb_recv_datagram+0x197/0x1f6
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013ce60>] ? trace_hardirqs_on_caller+0xe1/0x102
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0131211>] ? autoremove_wake_function+0x0/0x33
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c025f7a3>] skb_recv_datagram+0x20/0x25
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c02ab794>] unix_dgram_recvmsg+0x58/0x207
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c013b0fe>] ? trace_hardirqs_off+0xb/0xd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01085d7>] ? native_sched_clock+0x8b/0x9d
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0257bb4>] sock_aio_read+0xef/0xfd
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01682c0>] do_sync_read+0xab/0xe9
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0131211>] ? autoremove_wake_function+0x0/0x33
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c017459f>] ? locks_free_lock+0x3d/0x40
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c017459f>] ? locks_free_lock+0x3d/0x40
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c017556c>] ? fcntl_setlk64+0x165/0x16f
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0168b26>] vfs_read+0x94/0xed
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c0168c18>] sys_read+0x3b/0x60
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  [<c01038b9>] sysenter_do_call+0x12/0x35
Sep  5 01:20:16 Router-Dora user.warn kernel: [  246.974870]  =======================


