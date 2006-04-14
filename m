From: James Bourne <jbourne@hardrock.org>
Subject: via_rhine/qdisc Dead loop on netdevice eth1, fix it urgently!
Date: Fri, 14 Apr 2006 09:51:15 -0600 (MDT)
Message-ID: <Pine.LNX.4.58.0604140935220.4085@ldap2.hardrock.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from bama.hardrock.org ([68.146.16.251]:40329 "EHLO
	mail.hardrock.org") by vger.kernel.org with ESMTP id S1751254AbWDNPvT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 11:51:19 -0400
Received: from ldap2.hardrock.org (rio.clgy.hardrock.org [172.16.1.14])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.hardrock.org (Postfix) with ESMTP id 9C0105F5D6
	for <netdev@vger.kernel.org>; Fri, 14 Apr 2006 09:51:16 -0600 (MDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Had this happen this morning on my gateway box.  Any
o via rhine net device (eth1) and 8139too for eth0.
o kernel Linux bama.hardrock.org 2.6.16-1.2069_FC4 #1 Tue Mar 28 12:19:10 EST 2006 i686 athlon i386 GNU/Linux
o FC4 with all current patches, no binary modules in the kernel
o UP

If there's any other info required please email me, I'm not currently on the
list.

Regards
James

-- 
James Bourne                  | Email:            jbourne@hardrock.org          
UNIX Systems Administration   | WWW:           http://www.hardrock.org
Custom UNIX Programming       | Linux:  The choice of a GNU generation
----------------------------------------------------------------------
 "All you need's an occasional kick in the philosophy." Frank Herbert  

Apr 14 08:32:53 bama kernel: nfs: server 172.16.1.14 OK
Apr 14 08:32:53 bama kernel: nfs: server 172.16.1.14 OK
Apr 14 08:32:53 bama kernel: BUG: spinlock trylock failure on UP on CPU#0, df/9753 (Not tainted)
Apr 14 08:32:53 bama kernel:  lock: f7cd494c, .magic: dead4ead, .owner: df/9753, .owner_cpu: 0
Apr 14 08:32:53 bama kernel:  [<c01de996>] _raw_spin_trylock+0x39/0x3d     [<c03123fb>] _spin_trylock+0x5/0xe
Apr 14 08:32:53 bama kernel:  [<c02c1e0d>] qdisc_restart+0x37/0x1ec     [<c02b440a>] dev_queue_xmit+0x7d/0x2bd
Apr 14 08:32:53 bama kernel:  [<c02d4a9b>] ip_output+0x179/0x2be     [<c02d42a8>] ip_finish_output+0x0/0x22a
Apr 14 08:32:53 bama kernel:  [<c02d4059>] ip_queue_xmit+0x28c/0x4db     [<c02d18f0>] dst_output+0x0/0x7
Apr 14 08:32:53 bama kernel:  [<c0312433>] _spin_lock_irqsave+0x9/0xd     [<c0124173>] lock_timer_base+0x15/0x2f
Apr 14 08:32:53 bama kernel:  [<c03124c9>] _write_unlock_bh+0x5/0xa     [<c02e852d>] tcp_v4_send_check+0x38/0xcf
Apr 14 08:32:53 bama kernel:  [<c02e2d2b>] tcp_transmit_skb+0x3d2/0x700     [<c02def6c>] tcp_ack+0x6a0/0x193d
Apr 14 08:32:53 bama kernel:  [<c02e4bdd>] __tcp_push_pending_frames+0x128/0x3a6     [<c02e1c84>] tcp_rcv_established+0x268/0x724
Apr 14 08:32:53 bama kernel:  [<c02e8663>] tcp_v4_do_rcv+0x9f/0x2ec     [<c02e97fe>] tcp_v4_rcv+0x946/0x94d
Apr 14 08:32:54 bama kernel:  [<c02ced8c>] ip_local_deliver_finish+0x0/0x1b8     [<c02cf050>] ip_local_deliver+0x10c/0x248
Apr 14 08:32:54 bama kernel:  [<c02ced8c>] ip_local_deliver_finish+0x0/0x1b8     [<c02cf493>] ip_rcv+0x307/0x4d4
Apr 14 08:32:54 bama kernel:  [<c02ceaf8>] ip_rcv_finish+0x0/0x294     [<f886da0f>] rtl8139_poll+0x13d/0x4c6 [8139too]
Apr 14 08:32:54 bama kernel:  [<c02e59b4>] tcp_write_timer+0x37/0x5fc     [<c02b4a52>] netif_receive_skb+0x23b/0x310
Apr 14 08:32:54 bama kernel:  [<c02b4b92>] process_backlog+0x6b/0xfb     [<c02b3592>] net_rx_action+0x8a/0x17c
Apr 14 08:32:54 bama kernel:  [<c01211fb>] __do_softirq+0x3e/0x8a     [<c01050e6>] do_softirq+0x3e/0x48
Apr 14 08:32:54 bama kernel:  =======================
Apr 14 08:32:54 bama kernel:  [<c0105077>] do_IRQ+0x51/0x82     [<c01036e2>] common_interrupt+0x1a/0x20
Apr 14 08:32:54 bama kernel:  [<f887592e>] rhine_start_tx+0xff/0x256 [via_rhine]     [<c02beb5f>] find_skb+0x2e/0xe2
Apr 14 08:32:54 bama kernel:  [<c02becbb>] netpoll_send_skb+0xa8/0x100     [<f8c4c174>] write_msg+0x140/0x181 [netconsole]
Apr 14 08:32:54 bama kernel:  [<f8c4c034>] write_msg+0x0/0x181 [netconsole]     [<c011c288>] __call_console_drivers+0x38/0x44
Apr 14 08:32:54 bama kernel:  [<c011c455>] release_console_sem+0xb8/0x1e1     [<c011cf79>] vprintk+0x2bb/0x372
Apr 14 08:32:54 bama kernel:  [<c0312488>] _spin_unlock_irq+0x5/0x7     [<f8cd9666>] __rpc_do_wake_up_task+0x104/0x20d [sunrpc]
Apr 14 08:32:54 bama kernel:  [<c0312433>] _spin_lock_irqsave+0x9/0xd     [<c011d04f>] printk+0x1f/0xb9
Apr 14 08:32:54 bama kernel:  [<c03119d3>] __wait_on_bit+0x54/0x5e     [<f8cd9087>] rpc_wait_bit_interruptible+0x0/0x22 [sunrpc]
Apr 14 08:32:54 bama kernel:  [<f8cd4a51>] call_decode+0x136/0x569 [sunrpc]     [<c0124cbb>] del_timer+0x43/0x4b
Apr 14 08:32:54 bama kernel:  [<f8d2bc4e>] nfs3_xdr_fsstatres+0x0/0x100 [nfs]     [<f8cd9b40>] __rpc_execute+0x54/0x1c3 [sunrpc]
Apr 14 08:32:54 bama kernel:  [<f8cd572b>] rpc_call_sync+0x8c/0xa1 [sunrpc]     [<f8d28672>] nfs3_rpc_wrapper+0x42/0x79 [nfs]
Apr 14 08:32:54 bama kernel:  [<f8d2a29c>] nfs3_proc_statfs+0x69/0x9d [nfs]     [<f8d20224>] nfs_statfs+0x55/0x1bc [nfs]
Apr 14 08:32:54 bama kernel:  [<c01d955f>] _atomic_dec_and_lock+0x27/0x38     [<c016f1ef>] dput+0xb6/0x1bd
Apr 14 08:32:54 bama kernel:  [<c0166d63>] __follow_mount+0x45/0x6c     [<c01d955f>] _atomic_dec_and_lock+0x27/0x38
Apr 14 08:32:54 bama kernel:  [<c0172e70>] mntput_no_expire+0x13/0x71     [<c01678ff>] __link_path_walk+0xa25/0xeee
Apr 14 08:32:54 bama kernel:  [<c0158251>] vfs_statfs+0x48/0x5d     [<c0158276>] vfs_statfs64+0x10/0x21
Apr 14 08:32:54 bama kernel:  [<c0158353>] sys_statfs64+0x5f/0x97     [<c0159bd3>] vfs_write+0xfa/0x15a
Apr 14 08:32:54 bama kernel:  [<c015a4ca>] sys_write+0x41/0x6a     [<c0102d15>] syscall_call+0x7/0xb
Apr 14 08:32:54 bama kernel: Dead loop on netdevice eth1, fix it urgently!
Apr 14 08:32:54 bama last message repeated 3 times
Apr 14 08:32:54 bama kernel: nfs: server 172.16.1.14 OK
