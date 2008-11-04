From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [BUG] linux-2.6.26.7 : loading of sch_cbq is stuck
Date: Tue, 04 Nov 2008 11:45:13 +0100
Message-ID: <491027B9.2090403@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:57991 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307AbYKDKp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 05:45:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

Just found this problem on linux-2.6.26.7 when trying to add cbq on eth0

/proc/modules hangs too

root     12117  0.0  0.0   1560   360 pts/1    D+   11:07   0:00 lsmod
root     10361  0.0  0.0   1996   696 pts/0    D+   11:05   0:00 tc qdisc add dev eth0 root handle 1: cbq avpkt 1000 rate 100Mbit bandwidth 100Mbit
root     10362  0.0  0.0      0     0 ?        S<   11:05   0:00 [khelper]
root     10363  0.0  0.0   1592   588 ?        R    11:05   0:00 /sbin/modprobe -q -- sch_cbq
root     10364  0.0  0.0      0     0 ?        S<   11:05   0:00 [kstopmachine]
root     10365  0.0  0.0      0     0 ?        Z<   11:05   0:00 [kstopmachine] <defunct>
root     10366  0.0  0.0      0     0 ?        Z<   11:05   0:00 [kstopmachine] <defunct>
root     10367  0.0  0.0      0     0 ?        Z<   11:05   0:00 [kstopmachine] <defunct>

 SysRq : Show State
   task                PC stack   pid father
 init          S f7841b38     0     1      0
        f783fbc0 00000082 00000002 f7841b38 f7841b2c 00000000 c0358340 f783fd14
        f783fd14 c3396d00 f70dda80 c3393140 1d6bab5f ffffffff f7841b5c 1d6bbe90
        000000fb 00000282 00000001 00000000 00000000 f7841b5c 1d6bbe90 00000000
 Call Trace:
  [<c02ce2d5>] schedule_timeout+0x44/0xa1
  [<c012f847>] 8
  [<c01e1b66>] __next_cpu+0x12/0x21
  [<c01174d5>] find_busiest_group+0x195/0x74d
  [<c01190f9>] update_curr_rt+0x8e/0x357
  [<c0131ca3>] hrtimer_forward+0x72/0x109
  [<c0107c72>] read_tsc+0x6/0x28
  [<c0134480>] getnstimeofday+0x37/0xd3
  [<c013275e>] ktime_get_ts+0x16/0x3c
  [<c0137338>] clockevents_program_event+0x8f/0xe5
  [<c01382b1>] tick_dev_program_event+0x31/0x9d
  [<c0126d83>] run_timer_softirq+0x30/0x171
  [<c0138371>] tick_program_event+0x24/0x2a
  [<c01235f2>] __do_softirq+0x71/0xde
  [<c010f9cb>] smp_apic_timer_interrupt+0x5a/0x8f
  [<c010e8f4>] smp_call_function_interrupt+0x4e/0x64
  [<c01036ec>] apic_timer_interrupt+0x28/0x30
  =======================
 ccenter_sched S f64c3bec     0  7479   7471
        f65f1850 00200082 00000002 f64c3bec f64c3be0 00000000 f6ae4e00 f65f19a4
        f65f19a4 c33b4d00 f718c480 f7922000 1d6bac6a 00000000 f64c3c10 1d6bb052
        000000fb 00200286 00000001 00000000 00000000 f64c3c10 1d6bb052 00000000
 Call Trace:
  [<c02ce2d5>] schedule_timeout+0x44/0xa1
  [<c012f847>] add_wait_queue+0xf/0x38
  [<c0127017>] process_timeout+0x0/0x5
  [<c01727b3>] do_sys_poll+0x21a/0x318
  [<c017330f>] __pollwait+0x0/0xcf
  [<c011852e>] default_wake_function+0x0/0x8
Nov  4 11:32:51 arietis last message repeated 4 times
  [<c0266d76>] memcpy_toiovec+0x37/0x4e
  [<c0267364>] skb_copy_datagram_iovec+0x14c/0x1ff
  [<c02cf460>] _spin_lock_bh+0x8/0x1e
  [<c02cf460>] _spin_lock_bh+0x8/0x1e
  [<c0261a71>] release_sock+0x12/0x8f
  [<c029405f>] tcp_recvmsg+0x1ab/0x7e2
  [<c017c005>] mnt_drop_write+0x1d/0xcf
  [<c0261476>] sock_common_recvmsg+0x3e/0x54
  [<c025fc95>] sock_recvmsg+0xcf/0xf3
  [<c025fd75>] sock_sendmsg+0xbc/0xde
  [<c012f687>] autoremove_wake_function+0x0/0x37
  [<c010365c>] reschedule_interrupt+0x28/0x30
  [<c0131e66>] enqueue_hrtimer+0x72/0xee
  [<c025f6a7>] sockfd_lookup_light+0x24/0x41
  [<c011ace8>] hrtick_set+0x77/0xf4
  [<c01022c1>] do_notify_resume+0x4a/0x70b
  [<c012f687>] autoremove_wake_function+0x0/0x37
  [<c0260a99>] sys_recv+0x37/0x3b
  [<c0107c72>] read_tsc+0x6/0x28
  [<c0134480>] getnstimeofday+0x37/0xd3
  [<c01728e4>] sys_poll+0x33/0x73
  [<c0102ca6>] syscall_call+0x7/0xb
  =======================
 consistent_lo S 00000000     0  7480   7471
        f65f03b0 00200082 000000d0 00000000 c014c466 c035f400 00000001 f65f0504
        f65f0504 c3396d00 f714d880 00000010 00200282 c0127184 db9d1c10 1d6bb0ab
        db9d1c10 00200282 c0127292 00000000 00200282 db9d1c10 1d6bb0ab 00000000
 Call Trace:
  [<c014c466>] __alloc_pages_internal+0x9c/0x414
  [<c0127184>] lock_timer_base+0x19/0x35
  [<c0127292>] __mod_timer+0x8f/0x9e
  [<c02ce2d5>] schedule_timeout+0x44/0xa1
  [<c012f847>] add_wait_queue+0xf/0x38
  [<c0127017>] process_timeout+0x0/0x5
  [<c01727b3>] do_sys_poll+0x21a/0x318
  [<c017330f>] __pollwait+0x0/0xcf
  [<c011852e>] default_wake_function+0x0/0x8
Nov  4 11:32:51 arietis last message repeated 19 times
  [<c01675c1>] vfs_write+0xe9/0x118
  [<c0166cb0>] do_sync_write+0x0/0x10e
  [<c01728e4>] sys_poll+0x33/0x73
  [<c0102ca6>] syscall_call+0x7/0xb
  =======================
 ccenter_db_lo S f6777bec     0  7481   7471
        f795ca90 00200082 00000002 f6777bec f6777be0 00000000 f6ae5170 f795cbe4
        f795cbe4 c3396d00 f70ddc80 f7922000 00200282 c0127184 f6777c10 1d6bb0ac
        f6777c10 00200282 c0127292 00000000 00200282 f6777c10 1d6bb0ac 00000000
 Call Trace:
  [<c0127184>] lock_timer_base+0x19/0x35
  [<c0127292>] __mod_timer+0x8f/0x9e
  [<c02ce2d5>] schedule_timeout+0x44/0xa1
  [<c012f847>] add_wait_queue+0xf/0x38
  [<c0127017>] process_timeout+0x0/0x5
  [<c01727b3>] do_sys_poll+0x21a/0x318
  [<c017330f>] __pollwait+0x0/0xcf
  [<c011852e>] default_wake_function+0x0/0x8
Nov  4 11:32:51 arietis last message repeated 4 times
  [<c0117d23>] __wake_up+0x32/0x42
  [<c01bd2e8>] journal_stop+0x19a/0x264
  [<c01ad617>] ext3_generic_write_end+0x6f/0x88
  [<c01af4f7>] ext3_ordered_write_end+0xf0/0x14b
  [<c017c005>] mnt_drop_write+0x1d/0xcf
  [<c014814a>] generic_file_buffered_write+0x1a5/0x63c
  [<c017c005>] mnt_drop_write+0x1d/0xcf
  [<c01ceeff>] security_inode_need_killpriv+0xc/0xd
  [<c0146ede>] remove_suid+0x15/0x53
  [<c017c005>] mnt_drop_write+0x1d/0xcf
  [<c014887e>] __generic_file_aio_write_nolock+0x29d/0x555
  [<c0148b94>] generic_file_aio_write+0x5e/0xc5
  [<c0166d82>] do_sync_write+0xd2/0x10e
  [<c012f687>] autoremove_wake_function+0x0/0x37
  [<c0107c72>] read_tsc+0x6/0x28
  [<c0134480>] getnstimeofday+0x37/0xd3
  [<c01728e4>] sys_poll+0x33/0x73
  [<c0102ca6>] syscall_call+0x7/0xb
  =======================
 consistent_st S d690dbec     0  7482   7471
        f7927850 00200082 00000002 d690dbec d690dbe0 00000000 f783e720 f79279a4
        f79279a4 c33a0d00 f709ed80 f7922000 00200286 c0127184 d690dc10 1d6baf47
        d690dc10 00200286 c0127292 00000000 00200286 d690dc10 1d6baf47 00000000
 Call Trace:
  [<c0127184>] lock_timer_base+0x19/0x35
  [<c0127292>] __mod_timer+0x8f/0x9e
  [<c02ce2d5>] schedule_timeout+0x44/0xa1
  [<c012f847>] add_wait_queue+0xf/0x38
  [<c0127017>] process_timeout+0x0/0x5
  [<c01727b3>] do_sys_poll+0x21a/0x318
  [<c017330f>] __pollwait+0x0/0xcf
  [<c011852e>] default_wake_function+0x0/0x8
Nov  4 11:32:51 arietis last message repeated 11 times
  [<c025fc95>] sock_recvmsg+0xcf/0xf3
  [<c025fd75>] sock_sendmsg+0xbc/0xde
  [<c012f687>] autoremove_wake_function+0x0/0x37
  [<c0131e66>] enqueue_hrtimer+0x72/0xee
  [<c025f6a7>] sockfd_lookup_light+0x24/0x41
  [<c0107c72>] read_tsc+0x6/0x28
  [<c0134480>] getnstimeofday+0x37/0xd3
  [<c0101d08>] __switch_to+0x134/0x14b
  [<c011acce>] hrtick_set+0x5d/0xf4
  [<c02cdcf5>] schedule+0x231/0x6ff
  [<c0260a99>] sys_recv+0x37/0x3b
  [<c0107c72>] read_tsc+0x6/0x28
  [<c0134480>] getnstimeofday+0x37/0xd3
  [<c01728e4>] sys_poll+0x33/0x73
  [<c0102ca6>] syscall_call+0x7/0xb
  =======================
 ccenter_ccxml S dc277bec     0  7483   7471
        f735b4e0 00200082 00000002 dc277bec dc277be0 00000000 f65f03b0 f735b634
        f735b634 c3396d00 f7022680 c03c3b80 1d6bad5f ffffffff dc277c10 1d6bb0ab
        000000fb 00200282 00000001 00000000 00000000 dc277c10 1d6bb0ab 00000000
 Call Trace:
  [<c02ce2d5>] schedule_timeout+0x44/0xa1
  [<c012f847>] add_wait_queue+0xf/0x38
  [<c0127017>] process_timeout+0x0/0x5
  [<c01727b3>] do_sys_poll+0x21a/0x318
  [<c017330f>] __pollwait+0x0/0xcf
  [<c011852e>] default_wake_function+0x0/0x8
Nov  4 11:32:51 arietis last message repeated 10 times
  [<c017c005>] mnt_drop_write+0x1d/0xcf
  [<c025fd75>] sock_sendmsg+0xbc/0xde
  [<c012f687>] autoremove_wake_function+0x0/0x37
  [<c0131e66>] enqueue_hrtimer+0x72/0xee
  [<c0131ca3>] hrtimer_forward+0x72/0x109
  [<c026013b>] sys_send+0x37/0x3b
  [<c0107c72>] read_tsc+0x6/0x28
  [<c0134480>] getnstimeofday+0x37/0xd3
  [<c01728e4>] sys_poll+0x33/0x73
  [<c0102ca6>] syscall_call+0x7/0xb
  =======================
 ccenter_dispa S d686fbec     0  7484   7471
        f7926040 00200082 00000002 d686fbec d686fbe0 00000000 f795ca90 f7926194
        f7926194 c3396d00 f7238480 f7922000 1d6bad5f ffffffff d686fc10 1d6bb0ac
        000000fb 00200282 00000001 00000000 00000000 d686fc10 1d6bb0ac 00000000
 Call Trace:
  [<c02ce2d5>] schedule_timeout+0x44/0xa1
  [<c012f847>] add_wait_queue+0xf/0x38
  [<c0127017>] process_timeout+0x0/0x5
  [<c01727b3>] do_sys_poll+0x21a/0x318
  [<c017330f>] __pollwait+0x0/0xcf
  [<c011852e>] default_wake_function+0x0/0x8
Nov  4 11:32:51 arietis last message repeated 7 times
  [<c029405f>] tcp_recvmsg+0x1ab/0x7e2
  [<c017c005>] mnt_drop_write+0x1d/0xcf
  [<c0261476>] sock_common_recvmsg+0x3e/0x54
  [<c025fc95>] sock_recvmsg+0xcf/0xf3
  [<c025fd75>] sock_sendmsg+0xbc/0xde
  [<c012f687>] autoremove_wake_function+0x0/0x37
  [<c01165af>] kmap_atomic+0x1c/0x21
  [<c014c1db>] get_page_from_freelist+0x2a6/0x479
  [<c025f6a7>] sockfd_lookup_light+0x24/0x41
  [<c0131ca3>] hrtimer_forward+0x72/0x109
  [<c0156582>] handle_mm_fault+0x610/0x757
  [<c013275e>] ktime_get_ts+0x16/0x3c
  [<c0137338>] clockevents_program_event+0x8f/0xe5
  [<c0260a99>] sys_recv+0x37/0x3b
  [<c0107c72>] read_tsc+0x6/0x28
  [<c0134480>] getnstimeofday+0x37/0xd3
  [<c01728e4>] sys_poll+0x33/0x73
  [<c0102ca6>] syscall_call+0x7/0xb
  =======================
 sshd          S e41afd78     0  6642   3078
        f58f1850 00000086 e41aff48 e41afd78 e41aff48 c025fd75 f7047170 f58f19a4
        f58f19a4 c3396d00 f71cad00 ffffffff 00000000 00000000 00000000 00000000
        00000000 f58f1850 00000000 00000000 d627b0d4 f7353480 7fffffff 00000000
 Call Trace:
  [<c025fd75>] sock_sendmsg+0xbc/0xde
  [<c02ce2fa>] schedule_timeout+0x69/0xa1
  [<c012f79d>] prepare_to_wait+0x12/0x4a
  [<c02c4245>] unix_stream_recvmsg+0x35c/0x4e9
  [<c016dc28>] do_lookup+0x59/0x17d
  [<c012f687>] autoremove_wake_function+0x0/0x37
  [<c025f2f5>] sock_aio_read+0xd2/0xeb
  [<c01e2da1>] kobject_get+0xf/0x13
  [<c0166e90>] do_sync_read+0xd2/0x10e
  [<c0170d3d>] do_filp_open+0x177/0x733
  [<c012f687>] autoremove_wake_function+0x0/0x37
  [<c01cef26>] security_file_permission+0xc/0xd
  [<c0166f26>] rw_verify_area+0x5a/0xb5
  [<c0167703>] vfs_read+0x113/0x11a
  [<c0167ac2>] sys_read+0x41/0x6a
  [<c0102ca6>] syscall_call+0x7/0xb
  =======================
 sshd          S c9b8bb38     0  6647   6642
        f7047170 00000086 00000002 c9b8bb38 c9b8bb2c 00000000 c0358340 f70472c4
        f70472c4 c3396d00 f73aab00 00000003 1d5380bf ffffffff 00000000 00000001
        000000fb c0117d23 00000001 00000000 00000000 0000000a 00000000 00000000
 Call Trace:
  [<c0117d23>] __wake_up+0x32/0x42
  [<c02ce2fa>] schedule_timeout+0x69/0xa1
  [<c022fc7e>] tty_poll+0x57/0x61
  [<c0172d03>] do_select+0x395/0x472
  [<c017330f>] __pollwait+0x0/0xcf
  [<c011852e>] default_wake_function+0x0/0x8
Nov  4 11:32:51 arietis last message repeated 3 times
  [<c0279cd3>] __qdisc_run+0x78/0x19a
  [<c0282440>] nf_iterate+0x60/0x84
  [<c026c9fe>] dev_queue_xmit+0x95/0x327
  [<c028ca8e>] ip_finish_output+0x12a/0x290
  [<c028c627>] ip_local_out+0x15/0x17
  [<c028d0d9>] ip_queue_xmit+0x138/0x2e2
  [<c0138371>] tick_program_event+0x24/0x2a
  [<c023348c>] n_tty_receive_buf+0x2b7/0xf85
  [<c023348c>] n_tty_receive_buf+0x2b7/0xf85
  [<c0107c72>] read_tsc+0x6/0x28
  [<c029cc5c>] tcp_transmit_skb+0x3cd/0x74e
  [<c0127184>] lock_timer_base+0x19/0x35
  [<c0127292>] __mod_timer+0x8f/0x9e
  [<c0261bc4>] sk_reset_timer+0xc/0x16
  [<c029e291>] __tcp_push_pending_frames+0x10c/0x728
  [<c0266d76>] memcpy_toiovec+0x37/0x4e
  [<c02cf460>] _spin_lock_bh+0x8/0x1e
  [<c0261a71>] release_sock+0x12/0x8f
  [<c0293bb5>] tcp_sendmsg+0x783/0xa82
  [<c0235739>] pty_write+0x39/0x41
  [<c022e713>] tty_put_char+0x26/0x2b
  [<c0232a8d>] opost+0x94/0x1ef
  [<c0172f99>] core_sys_select+0x1b9/0x2c2
  [<c025f209>] sock_aio_write+0xcb/0xe5
  [<c023162d>] tty_ioctl+0xe2/0xd32
  [<c0166d82>] do_sync_write+0xd2/0x10e
  [<c012f687>] autoremove_wake_function+0x0/0x37
  [<c017341d>] sys_select+0x3f/0x1ad
  [<c0167b2c>] sys_write+0x41/0x6a
  [<c0102ca6>] syscall_call+0x7/0xb
  =======================
 bash          S c94bbf00     0  6648   6647
        c69f0e00 00000082 00000002 c94bbf00 c94bbef4 00000000 00100173 c69f0f54
        c69f0f54 c33aad00 f6ae2380 00000000 1d4f02b2 ffffffff c035c864 c114784c
        000000ff e6134fe0 00000000 00000000 00000000 c69f0e00 c69f0df8 0000000e
 Call Trace:
  [<c01215f0>] do_wait+0x53e/0xada
  [<c011c4a2>] task_new_fair+0x5b/0xab
  [<c023154b>] tty_ioctl+0x0/0xd32
  [<c011852e>] default_wake_function+0x0/0x8
  [<c0121bf5>] sys_wait4+0x69/0xa4
  [<c0121c57>] sys_waitpid+0x27/0x2b
  [<c0102ca6>] syscall_call+0x7/0xb
  [<c02c0000>] xfrm_hash_resize+0x1b7/0x2b3
  =======================
 pickup        S e4253b38     0  6662   3059
        f58f1170 00200086 00000002 e4253b38 e4253b2c 00000000 f7046040 f58f12c4
        f58f12c4 c3396d00 f7e14100 f7477a98 1d6b5f5e ffffffff e4253b5c 1d6ce466
        000000fb 00200282 00000001 00000000 00000000 e4253b5c 1d6ce466 00000000
 Call Trace:
  [<c02ce2d5>] schedule_timeout+0x44/0xa1
  [<c012f847>] add_wait_queue+0xf/0x38
  [<c0127017>] process_timeout+0x0/0x5
  [<c0172d03>] do_select+0x395/0x472
  [<c017330f>] __pollwait+0x0/0xcf
  [<c011852e>] default_wake_function+0x0/0x8
  [<c011852e>] default_wake_function+0x0/0x8
  [<c0185939>] __getblk+0x23/0x294
  [<c01854b5>] __find_get_block_slow+0x75/0x116
  [<c01165af>] kmap_atomic+0x1c/0x21
  [<c0185811>] __find_get_block+0x87/0x18c
  [<c0185811>] __find_get_block+0x87/0x18c
  [<c014c466>] __alloc_pages_internal+0x9c/0x414
  [<c01c118f>] find_revoke_record+0x54/0x83
  [<c01c1614>] journal_cancel_revoke+0xa1/0x184
  [<c0134480>] getnstimeofday+0x37/0xd3
  [<c01854b5>] __find_get_block_slow+0x75/0x116
  [<c01182a7>] task_rq_lock+0x29/0x50
  [<c011849f>] try_to_wake_up+0x5e/0xed
  [<c0116d95>] __wake_up_common+0x46/0x68
  [<c0117d68>] __wake_up_sync+0x35/0x4d
  [<c0172f99>] core_sys_select+0x1b9/0x2c2
  [<c025f209>] sock_aio_write+0xcb/0xe5
  [<c0166d82>] do_sync_write+0xd2/0x10e
  [<c0117d23>] __wake_up+0x32/0x42
  [<c0107c72>] read_tsc+0x6/0x28
  [<c0134480>] getnstimeofday+0x37/0xd3
  [<c0131e66>] enqueue_hrtimer+0x72/0xee
  [<c0132577>] hrtimer_start+0xb6/0x13b
  [<c01734c3>] sys_select+0xe5/0x1ad
  [<c0122bae>] alarm_setitimer+0x36/0x64
  [<c0102ca6>] syscall_call+0x7/0xb
  =======================
 bash          S 00000000     0  6669   6648
        f72ad4e0 00000086 b12e7065 00000000 c011ace8 fff9d000 ffffffff f72ad634
        f72ad634 c33aad00 f70f9d00 00000000 c138700c c01022c1 00000082 c138700c
        16b5c200 d6b5c200 00000000 c015650b 00000246 f72ad4e0 f72ad4d8 0000000e
 Call Trace:
  [<c011ace8>] hrtick_set+0x77/0xf4
  [<c01022c1>] do_notify_resume+0x4a/0x70b
  [<c015650b>] handle_mm_fault+0x599/0x757
  [<c01215f0>] do_wait+0x53e/0xada
  [<c023154b>] tty_ioctl+0x0/0xd32
  [<c011852e>] default_wake_function+0x0/0x8
  [<c0121bf5>] sys_wait4+0x69/0xa4
  [<c0121c57>] sys_waitpid+0x27/0x2b
  [<c0102ca6>] syscall_call+0x7/0xb
  =======================
 bash          S c91adf00     0 10359   6669
        f7954a90 00000082 00000002 c91adf00 c91adef4 00000000 00000000 f7954be4
        f7954be4 c3396d00 f65ed280 c91adfb8 1d537ebf ffffffff 00010000 c10a48ec
        000000fb 00000002 00000001 00000000 00000000 f7954a90 f7954a88 00000004
 Call Trace:
  [<c01215f0>] do_wait+0x53e/0xada
  [<c011c4a2>] task_new_fair+0x5b/0xab
  [<c011852e>] default_wake_function+0x0/0x8
  [<c0121bf5>] sys_wait4+0x69/0xa4
  [<c0121c57>] sys_waitpid+0x27/0x2b
  [<c0102ca6>] syscall_call+0x7/0xb
  =======================
 tc            D c9b01b40     0 10361  10359
        f6b60720 00000082 00000002 c9b01b40 c9b01b34 00000000 c0116a31 f6b60874
        f6b60874 c33aad00 f65ed080 00000092 1d529e0f 00000000 00000000 00000001
        000000fd 00000000 00000001 00000000 00000000 c9b01bb4 7fffffff 00000002
 Call Trace:
  [<c0116a31>] activate_task+0x1c/0x24
  [<c02ce2fa>] schedule_timeout+0x69/0xa1
  [<c0117d23>] __wake_up+0x32/0x42
  [<c02cd9c9>] wait_for_common+0x9c/0x12a
  [<c011852e>] default_wake_function+0x0/0x8
  [<c012c577>] call_usermodehelper_exec+0xa7/0xac
  [<c012c6d8>] request_module+0x9f/0xe2
  [<c026c080>] netdev_run_todo+0x27/0x227
  [<c027ab46>] qdisc_create+0x1ae/0x1e4
  [<c027b4a1>] tc_modify_qdisc+0x85/0x3c8
  [<c027b41c>] tc_modify_qdisc+0x0/0x3c8
  [<c027320f>] rtnetlink_rcv_msg+0x1bb/0x1ee
  [<c0273054>] rtnetlink_rcv_msg+0x0/0x1ee
  [<c027fa88>] netlink_rcv_skb+0x74/0x91
  [<c027304e>] rtnetlink_rcv+0x14/0x1a
  [<c027f87a>] netlink_unicast+0x235/0x25d
  [<c027ffc3>] netlink_sendmsg+0x1cb/0x290
  [<c025fd75>] sock_sendmsg+0xbc/0xde
  [<c012f687>] autoremove_wake_function+0x0/0x37
  [<c012f687>] autoremove_wake_function+0x0/0x37
  [<c025fd75>] sock_sendmsg+0xbc/0xde
  [<c016dc28>] do_lookup+0x59/0x17d
  [<c0266db7>] verify_iovec+0x2a/0x83
  [<c025fec4>] sys_sendmsg+0x12d/0x243
  [<c014c466>] __alloc_pages_internal+0x9c/0x414
  [<c0156582>] handle_mm_fault+0x610/0x757
  [<c015811c>] acct_stack_growth+0x82/0x98
  [<c0261014>] sys_socketcall+0x24f/0x271
  [<c0113a80>] do_page_fault+0x0/0x820
  [<c0102ca6>] syscall_call+0x7/0xb
  [<c02c0000>] xfrm_hash_resize+0x1b7/0x2b3
  =======================
 khelper       S c9351f28     0 10362     15
        f6a6c720 00000046 00000002 c9351f28 c9351f1c 00000000 00000002 f6a6c874
        f6a6c874 c33aad00 f65ed080 c3396d00 1d529e0f ffffffff c3396d00 f65f14e0
        000000ff c011c9d0 00000000 00000000 00000000 f6a6c720 f6a6c718 00000004
 Call Trace:
  [<c011c9d0>] wake_up_new_task+0x87/0xa2
  [<c01215f0>] do_wait+0x53e/0xada
  [<c012c71b>] ____call_usermodehelper+0x0/0x135
  [<c011852e>] default_wake_function+0x0/0x8
  [<c0121bf5>] sys_wait4+0x69/0xa4
  [<c012c600>] wait_for_helper+0x47/0x80
  [<c012c5b9>] wait_for_helper+0x0/0x80
  [<c010386f>] kernel_thread_helper+0x7/0x18
  =======================
 modprobe      R running      0 10363  10362
        f65f14e0 00000082 00000000 00000000 00000000 c8ec9e24 7fffffff f65f1634
        f65f1634 c33aad00 f714d480 c0358340 c0358368 00000046 00000046 866d34ea
        0001bf7b c33ab180 1d529e18 000001d3 00000000 c8ec9e58 7fffffff 00000002
 Call Trace:
  [<c02ce2fa>] schedule_timeout+0x69/0xa1
  [<c0133add>] sched_clock_cpu+0xa8/0x121
  [<c011c936>] check_preempt_wakeup+0xa1/0xb4
  [<c02cd9c9>] wait_for_common+0x9c/0x12a
  [<c011852e>] default_wake_function+0x0/0x8
  [<c013fcef>] __stop_machine_run+0x83/0x9e
  [<c013fd21>] do_stop+0x0/0x110
  [<c013b3c4>] __link_module+0x0/0x1f
  [<c013fd0f>] stop_machine_run+0x5/0x17
  [<c013ddf2>] sys_init_module+0x17b7/0x1d41
  [<c01e3c3f>] prio_tree_insert+0x1f/0x23b
  [<c02797f2>] qdisc_lock_tree+0x0/0x1c
  [<c0113bab>] do_page_fault+0x12b/0x820
  [<c0102ca6>] syscall_call+0x7/0xb
  [<c012007b>] log_buf_copy+0x16/0xab
  =======================
 kstopmachine  S 00000086     0 10364      2
        f6b61bc0 00000046 f65f14e0 00000086 c011849f 00000003 00000086 f6b61d14
        f6b61d14 c33aad00 f714d480 c0116d95 00000000 00000003 c8ec9e60 c8ec9e58
        c8ec9e5c 00000282 00000000 c0117ce2 00000000 00000001 00000000 c8ec9e50
 Call Trace:
  [<c011849f>] try_to_wake_up+0x5e/0xed
  [<c0116d95>] __wake_up_common+0x46/0x68
  [<c0117ce2>] complete+0x37/0x46
  [<c013fe00>] do_stop+0xdf/0x110
  [<c013fd21>] do_stop+0x0/0x110
  [<c012f3cd>] kthread+0x34/0x55
  [<c012f399>] kthread+0x0/0x55
  [<c010386f>] kernel_thread_helper+0x7/0x18
  =======================
 kstopmachine  ? e4cb5f88     0 10365  10364
        f7070720 00000046 00000002 e4cb5f88 e4cb5f7c 00000000 f7070720 f7070874
        f7070874 c3396d00 f7017100 f7070720 1d529e18 ffffffff f78e7ac4 f7070720
        000000fb c013247a 00000001 00000000 00000000 00000000 f7070720 00000000
 Call Trace:
  [<c013247a>] hrtimer_try_to_cancel+0x33/0x66
  [<c012217b>] do_exit+0x477/0x6e6
  [<c013fe31>] stopmachine+0x0/0xaf
  [<c0103875>] kernel_thread_helper+0xd/0x18
  =======================
 kstopmachine  ? 866db1c8     0 10366  10364
        f658dbc0 00000046 c33a1180 866db1c8 00000246 c011acce f658dbc0 f658dd14
        f658dd14 c33a0d00 f7351380 f658dbc0 00000286 c01323f7 f65fbb44 f658dbc0
        00000000 c013247a 00000000 00000000 f658dbc0 00000000 f658dbc0 00000000
 Call Trace:
  [<c011acce>] hrtick_set+0x5d/0xf4
  [<c01323f7>] lock_hrtimer_base+0x15/0x2f
  [<c013247a>] hrtimer_try_to_cancel+0x33/0x66
  [<c012217b>] do_exit+0x477/0x6e6
  [<c013fe31>] stopmachine+0x0/0xaf
  [<c0103875>] kernel_thread_helper+0xd/0x18
  =======================
 kstopmachine  ? e56aff88     0 10367  10364
        f6577bc0 00000046 00000002 e56aff88 e56aff7c 00000000 f6577bc0 f6577d14
        f6577d14 c33b4d00 f7072680 f6577bc0 1d529fae ffffffff f72ec744 f6577bc0
        000000fd c013247a 00000001 00000000 00000000 00000000 f6577bc0 00000000
 Call Trace:
  [<c013247a>] hrtimer_try_to_cancel+0x33/0x66
  [<c012217b>] do_exit+0x477/0x6e6
  [<c013fe31>] stopmachine+0x0/0xaf
  [<c0103875>] kernel_thread_helper+0xd/0x18
  =======================
 sshd          S c9ba5da8     0 11234   3078
        f792ee00 00000082 00000002 c9ba5da8 c9ba5d9c 00000000 f795c040 f792ef54
        f792ef54 c3396d00 f718cc80 ffffffff 1d53e8bf ffffffff 00000000 00000000
        000000fb f792ee00 00000001 00000000 00000000 f6a1e180 7fffffff 00000000
 Call Trace:
  [<c02ce2fa>] schedule_timeout+0x69/0xa1
  [<c012f79d>] prepare_to_wait+0x12/0x4a
  [<c02c4245>] unix_stream_recvmsg+0x35c/0x4e9
  [<c016dc28>] do_lookup+0x59/0x17d
  [<c012f687>] autoremove_wake_function+0x0/0x37
  [<c025f2f5>] sock_aio_read+0xd2/0xeb
  [<c01e2da1>] kobject_get+0xf/0x13
  [<c0166e90>] do_sync_read+0xd2/0x10e
  [<c0170d3d>] do_filp_open+0x177/0x733
  [<c012f687>] autoremove_wake_function+0x0/0x37
  [<c01cef26>] security_file_permission+0xc/0xd
  [<c0166f26>] rw_verify_area+0x5a/0xb5
  [<c0167703>] vfs_read+0x113/0x11a
  [<c0167ac2>] sys_read+0x41/0x6a
  [<c0102ca6>] syscall_call+0x7/0xb
  =======================
 sshd          S f62e1b38     0 11238  11234
        f795c040 00000086 00000002 f62e1b38 f62e1b2c 00000000 c0358340 f795c194
        f795c194 c3396d00 f71cab00 00000003 1d5c02a3 ffffffff 00000000 00000001
        000000fb c0117d23 00000001 00000000 00000000 0000000a 00000000 00000000
 Call Trace:
  [<c0117d23>] __wake_up+0x32/0x42
  [<c02ce2fa>] schedule_timeout+0x69/0xa1
  [<c022fc7e>] tty_poll+0x57/0x61
  [<c0172d03>] do_select+0x395/0x472
  [<c017330f>] __pollwait+0x0/0xcf
  [<c011852e>] default_wake_function+0x0/0x8
Nov  4 11:32:51 arietis last message repeated 3 times
  [<c0279cd3>] __qdisc_run+0x78/0x19a
  [<c0282440>] nf_iterate+0x60/0x84
  [<c026c9fe>] dev_queue_xmit+0x95/0x327
  [<c028ca8e>] ip_finish_output+0x12a/0x290
  [<c028c627>] ip_local_out+0x15/0x17
  [<c028d0d9>] ip_queue_xmit+0x138/0x2e2
  [<c023348c>] n_tty_receive_buf+0x2b7/0xf85
  [<c023348c>] n_tty_receive_buf+0x2b7/0xf85
  [<c029cc5c>] tcp_transmit_skb+0x3cd/0x74e
  [<c0127184>] lock_timer_base+0x19/0x35
  [<c0127292>] __mod_timer+0x8f/0x9e
  [<c0261bc4>] sk_reset_timer+0xc/0x16
  [<c029e291>] __tcp_push_pending_frames+0x10c/0x728
  [<c0266d76>] memcpy_toiovec+0x37/0x4e
  [<c02cf460>] _spin_lock_bh+0x8/0x1e
  [<c0261a71>] release_sock+0x12/0x8f
  [<c0293bb5>] tcp_sendmsg+0x783/0xa82
  [<c0235739>] pty_write+0x39/0x41
  [<c022e713>] tty_put_char+0x26/0x2b
  [<c0232747>] put_tty_queue+0x23/0x30
  [<c0172f99>] core_sys_select+0x1b9/0x2c2
  [<c025f209>] sock_aio_write+0xcb/0xe5
  [<c023162d>] tty_ioctl+0xe2/0xd32
  [<c0166d82>] do_sync_write+0xd2/0x10e
  [<c012f687>] autoremove_wake_function+0x0/0x37
  [<c017341d>] sys_select+0x3f/0x1ad
  [<c0167b2c>] sys_write+0x41/0x6a
  [<c0102ca6>] syscall_call+0x7/0xb
  =======================
 bash          S c3807f00     0 11239  11238
        f795d850 00000082 00000002 c3807f00 c3807ef4 00000000 db943ff0 f795d9a4
        f795d9a4 c33a0d00 f7127980 00000000 1d53f8be ffffffff c035c864 c14e04ac
        000000ff d31ec200 00000000 00000000 00000000 f795d850 f795d848 0000000e
 Call Trace:
  [<c01215f0>] do_wait+0x53e/0xada
  [<c011c4a2>] task_new_fair+0x5b/0xab
  [<c023154b>] tty_ioctl+0x0/0xd32
  [<c011852e>] default_wake_function+0x0/0x8
  [<c0121bf5>] sys_wait4+0x69/0xa4
  [<c0121c57>] sys_waitpid+0x27/0x2b
  [<c0102ca6>] syscall_call+0x7/0xb
  [<c02c0000>] xfrm_hash_resize+0x1b7/0x2b3
  =======================
 bash          S 00000000     0 11668  11239
        f705ca90 00000082 ca0d5065 00000000 c011ace8 fff90000 ffffffff f705cbe4
        f705cbe4 c33b4d00 f7127380 00000000 c10a20ac c01022c1 00000082 c10a20ac
        16b5b200 d6b5b200 00000000 c015650b 00000246 f705ca90 f705ca88 0000000e
 Call Trace:
  [<c011ace8>] hrtick_set+0x77/0xf4
  [<c01022c1>] do_notify_resume+0x4a/0x70b
  [<c015650b>] handle_mm_fault+0x599/0x757
  [<c01215f0>] do_wait+0x53e/0xada
  [<c023154b>] tty_ioctl+0x0/0xd32
  [<c011852e>] default_wake_function+0x0/0x8
  [<c0121bf5>] sys_wait4+0x69/0xa4
  [<c0121c57>] sys_waitpid+0x27/0x2b
  [<c0102ca6>] syscall_call+0x7/0xb
  =======================
 lsmod         D ca1f7edc     0 12117  11668
        f5a20a90 00000082 00000002 ca1f7edc ca1f7ed0 00000000 00000000 f5a20be4
        f5a20be4 c33a0d00 f718c880 c1267400 1d54d6f0 00000000 000000d0 c0163fbe
        000000fb f7803464 00000001 00000000 00000000 c035ce88 c035ce90 c035ce8c
 Call Trace:
  [<c0163fbe>] cache_alloc_refill+0x5b/0x4c9
  [<c02ce68d>] __mutex_lock_slowpath+0x54/0x88
  [<c02ce505>] mutex_lock+0xa/0xb
  [<c013b6a7>] m_start+0xd/0x1d
  [<c017f6c9>] seq_read+0xd7/0x29f
  [<c017f5f2>] seq_read+0x0/0x29f
  [<c01992c2>] proc_reg_read+0x52/0x6f
  [<c0167679>] vfs_read+0x89/0x11a
  [<c0199270>] proc_reg_read+0x0/0x6f
  [<c0167ac2>] sys_read+0x41/0x6a
  [<c0102ca6>] syscall_call+0x7/0xb
  =======================
 sshd          S c8d3bda8     0 16827   3078
        f78fc3b0 00000082 00000002 c8d3bda8 c8d3bd9c 00000000 f5a214e0 f78fc504
        f78fc504 c3396d00 f7351780 ffffffff 1d5a08a2 ffffffff 00000000 00000000
        000000fb f78fc3b0 00000001 00000000 00000000 f6a1e780 7fffffff 00000000
 Call Trace:
  [<c02ce2fa>] schedule_timeout+0x69/0xa1
  [<c012f79d>] prepare_to_wait+0x12/0x4a
  [<c02c4245>] unix_stream_recvmsg+0x35c/0x4e9
  [<c016dc28>] do_lookup+0x59/0x17d
  [<c012f687>] autoremove_wake_function+0x0/0x37
  [<c025f2f5>] sock_aio_read+0xd2/0xeb
  [<c01e2da1>] kobject_get+0xf/0x13
  [<c0166e90>] do_sync_read+0xd2/0x10e
  [<c0170d3d>] do_filp_open+0x177/0x733
  [<c012f687>] autoremove_wake_function+0x0/0x37
  [<c01cef26>] security_file_permission+0xc/0xd
  [<c0166f26>] rw_verify_area+0x5a/0xb5
  [<c0167703>] vfs_read+0x113/0x11a
  [<c0167ac2>] sys_read+0x41/0x6a
  [<c0102ca6>] syscall_call+0x7/0xb
  =======================
 sshd          S c93efb38     0 16831  16827
        f5a214e0 00000086 00000002 c93efb38 c93efb2c 00000000 c0358340 f5a21634
        f5a21634 c3396d00 f71ca700 00000003 1d6baf5f ffffffff 00000000 00000001
        000000fb c0117d23 00000001 00000000 00000000 0000000a 00000000 00000000
 Call Trace:
  [<c0117d23>] __wake_up+0x32/0x42
  [<c02ce2fa>] schedule_timeout+0x69/0xa1
  [<c022fc7e>] tty_poll+0x57/0x61
  [<c0172d03>] do_select+0x395/0x472
  [<c017330f>] __pollwait+0x0/0xcf
  [<c011852e>] default_wake_function+0x0/0x8
Nov  4 11:32:51 arietis last message repeated 3 times
  [<f8a88469>] ipt_do_table+0x1e0/0x323 [ip_tables]
  [<c0279cd3>] __qdisc_run+0x78/0x19a
  [<c0282440>] nf_iterate+0x60/0x84
  [<c026c9fe>] dev_queue_xmit+0x95/0x327
  [<c028ca8e>] ip_finish_output+0x12a/0x290
  [<c028c627>] ip_local_out+0x15/0x17
  [<c028d0d9>] ip_queue_xmit+0x138/0x2e2
  [<c028ca8e>] ip_finish_output+0x12a/0x290
  [<c023348c>] n_tty_receive_buf+0x2b7/0xf85
  [<c029cc5c>] tcp_transmit_skb+0x3cd/0x74e
  [<c0127184>] lock_timer_base+0x19/0x35
  [<c0127292>] __mod_timer+0x8f/0x9e
  [<c0261bc4>] sk_reset_timer+0xc/0x16
  [<c029e291>] __tcp_push_pending_frames+0x10c/0x728
  [<c02cf460>] _spin_lock_bh+0x8/0x1e
  [<c0261a71>] release_sock+0x12/0x8f
  [<c0293bb5>] tcp_sendmsg+0x783/0xa82
  [<c0117d23>] __wake_up+0x32/0x42
  [<c0172f99>] core_sys_select+0x1b9/0x2c2
  [<c025f209>] sock_aio_write+0xcb/0xe5
  [<c0166d82>] do_sync_write+0xd2/0x10e
  [<c012f687>] autoremove_wake_function+0x0/0x37
  [<c017341d>] sys_select+0x3f/0x1ad
  [<c0167b2c>] sys_write+0x41/0x6a
  [<c0102ca6>] syscall_call+0x7/0xb
  =======================
 bash          S e4263f00     0 16832  16831
        f5a203b0 00000086 00000002 e4263f00 e4263ef4 00000000 dc1f5ff8 f5a20504
        f5a20504 c33b4d00 f70b8300 00000000 1d5a0f2e ffffffff c035c864 c109264c
        000000ff c4b11200 00000000 00000000 00000000 f5a203b0 f5a203a8 0000000e
 Call Trace:
  [<c01215f0>] do_wait+0x53e/0xada
  [<c011c4a2>] task_new_fair+0x5b/0xab
  [<c023154b>] tty_ioctl+0x0/0xd32
  [<c011852e>] default_wake_function+0x0/0x8
  [<c0121bf5>] sys_wait4+0x69/0xa4
  [<c0121c57>] sys_waitpid+0x27/0x2b
  [<c0102ca6>] syscall_call+0x7/0xb
  [<c02c0000>] xfrm_hash_resize+0x1b7/0x2b3
  =======================
 bash          R running      0 16846  16832
        00000046 c011f4ee 00000046 ffff8000 c03d52e7 00000000 c03d52e6 00000092
        00000001 00000009 c03168c1 00000001 c02c0000 c0103b24 00000082 00000001
        00000096 00000001 0000000a c0103bce c31be5c0 00000000 c0316783 c8f13ec3
 Call Trace:
  [<c011f4ee>] release_console_sem+0x197/0x1c8
  [<c011f4ee>] release_console_sem+0x197/0x1c8
  [<c011fa1c>] printk+0x1b/0x1f
  [<c011fa1c>] printk+0x1b/0x1f
  [<c0103b24>] print_trace_address+0x39/0x43
  [<c012d9e1>] __kernel_text_address+0x18/0x23
  [<c010fcb8>] touch_nmi_watchdog+0x3a/0x40
  [<c0103b78>] dump_trace+0x4a/0xe9
  [<c0103c38>] show_trace_log_lvl+0x21/0x37
  [<c0103cfe>] show_stack_log_lvl+0xb0/0xd8
  [<c010442d>] show_stack+0x2f/0x35
  [<c011bd32>] show_state_filter+0x4f/0x71
  [<c02407cb>] __handle_sysrq+0x7a/0x115
  [<c019ef5e>] write_sysrq_trigger+0x0/0x2d
  [<c019ef89>] write_sysrq_trigger+0x2b/0x2d
  [<c0199331>] proc_reg_write+0x52/0x6f
  [<c0167563>] vfs_write+0x8b/0x118
  [<c01992df>] proc_reg_write+0x0/0x6f
  [<c0167b2c>] sys_write+0x41/0x6a
  [<c0102ca6>] syscall_call+0x7/0xb
  [<c02c0000>] xfrm_hash_resize+0x1b7/0x2b3
  =======================

