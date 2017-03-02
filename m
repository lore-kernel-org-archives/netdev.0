From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [4.9.13] use after free in ipv4_mtu
Date: Thu, 02 Mar 2017 05:08:24 -0800
Message-ID: <1488460104.9415.325.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAMVG2ssDe2NMOZzeTF77H1zEEh3dBuT75bS6f81Tqd+3v_4J+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Stephen Hemminger <shemminger@vyatta.com>
To: Daniel J Blueman <daniel@quora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35061 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752587AbdCBNJb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 08:09:31 -0500
Received: by mail-pg0-f66.google.com with SMTP id 1so9317355pgz.2
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 05:08:26 -0800 (PST)
In-Reply-To: <CAMVG2ssDe2NMOZzeTF77H1zEEh3dBuT75bS6f81Tqd+3v_4J+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-02 at 20:42 +0800, Daniel J Blueman wrote:
> With debugging enabled [1,2], KASAN finds a use-after-free in ipv4_mtu
> [3,4] with activity over a brcmfmac wireless card.
> 
> Let me know for further testing/debugging.
> 
> Thanks!
>   Dan
> 
> [1] https://quora.org/linux/ipv4_mtu/config
> [2] https://quora.org/linux/ipv4_mtu/vmlinux
> 
> -- [3]
> 
> BUG: KASAN: use-after-free in ipv4_mtu+0x25d/0x320 at addr ffff8803dd32e3cc
> Read of size 4 by task https/2070
> CPU: 3 PID: 2070 Comm: https Not tainted 4.9.13-debug+ #8
> Hardware name: Dell Inc. XPS 15 9550/0N7TVV, BIOS 1.2.19 12/22/2016
>  ffff88040e897690 ffffffff944db781 ffff88042740f740 ffff8803dd32e3c8
>  ffff88040e8976b8 ffffffff93e4d9e1 ffff88040e897750 ffff8803dd32e3c0
>  ffff88042740f740 ffff88040e897740 ffffffff93e4dc7a ffffffff93e471f2
> Call Trace:
>  [<ffffffff944db781>] dump_stack+0x85/0xc4
>  [<ffffffff93e4d9e1>] kasan_object_err+0x21/0x70
>  [<ffffffff93e4dc7a>] kasan_report_error+0x1fa/0x500
>  [<ffffffff93e471f2>] ? __slab_alloc.isra.60+0x72/0xa0
>  [<ffffffff93e4e0c1>] __asan_report_load4_noabort+0x61/0x70
>  [<ffffffff9505d5cd>] ? ipv4_mtu+0x25d/0x320
>  [<ffffffff9505d5cd>] ipv4_mtu+0x25d/0x320
>  [<ffffffff950fca39>] tcp_current_mss+0x149/0x2f0
>  [<ffffffff950fc8f0>] ? tcp_mtu_to_mss+0x360/0x360
>  [<ffffffff93e4d0c1>] ? memset+0x31/0x40
>  [<ffffffff94f40406>] ? __alloc_skb+0x316/0x5a0
>  [<ffffffff94f400f0>] ? skb_checksum+0xa0/0xa0
>  [<ffffffff93a8d0c8>] ? mark_held_locks+0xc8/0x120
>  [<ffffffff9398e57f>] ? __local_bh_enable_ip+0x6f/0xd0
>  [<ffffffff9510f2db>] tcp_send_fin+0x15b/0xbc0
>  [<ffffffff950c43e1>] tcp_close+0xc41/0xf50
>  [<ffffffff93ad9a87>] ? debug_lockdep_rcu_enabled+0x77/0x90
>  [<ffffffff93f88a40>] ? __fsnotify_update_child_dentry_flags.part.1+0x270/0x270
>  [<ffffffff9518003e>] inet_release+0xde/0x1c0
>  [<ffffffff94f19718>] sock_release+0x88/0x1a0
>  [<ffffffff94f19842>] sock_close+0x12/0x20
>  [<ffffffff93eb7f51>] __fput+0x261/0x740
>  [<ffffffff93eb849e>] ____fput+0xe/0x10
>  [<ffffffff939e076e>] task_work_run+0xde/0x150
>  [<ffffffff93989617>] do_exit+0x727/0x2cf0
>  [<ffffffff93a8dca0>] ? debug_check_no_locks_freed+0x290/0x290
>  [<ffffffff93988ef0>] ? mm_update_next_owner+0x720/0x720
>  [<ffffffff93ad9a87>] ? debug_lockdep_rcu_enabled+0x77/0x90
>  [<ffffffff939af064>] ? get_signal+0x1b4/0x1340
>  [<ffffffff9398bd39>] do_group_exit+0xf9/0x300
>  [<ffffffff939af345>] get_signal+0x495/0x1340
>  [<ffffffff93ef3400>] ? do_select+0x1380/0x1380
>  [<ffffffff9388fc73>] do_signal+0x93/0x1920
>  [<ffffffff93ee4ed1>] ? putname+0xc1/0xf0
>  [<ffffffff93ef16b0>] ? set_fd_set+0x70/0x70
>  [<ffffffff9388fbe0>] ? setup_sigcontext+0x7e0/0x7e0
>  [<ffffffff93ef3bef>] ? SyS_select+0x15f/0x1c0
>  [<ffffffff93ef3a90>] ? core_sys_select+0x690/0x690
>  [<ffffffff9380497a>] ? exit_to_usermode_loop+0x8a/0x130
>  [<ffffffff938049ab>] exit_to_usermode_loop+0xbb/0x130
>  [<ffffffff938075cc>] syscall_return_slowpath+0x16c/0x1a0
>  [<ffffffff953d84e6>] entry_SYSCALL_64_fastpath+0xc4/0xc6
> Object at ffff8803dd32e3c8, in cache kmalloc-64 size: 64
> Allocated:
> PID = 1598
>  save_stack_trace+0x1b/0x20
>  save_stack+0x46/0xd0
>  kasan_kmalloc+0xad/0xe0
>  kmem_cache_alloc_trace+0x136/0x340
>  fib_create_info+0x912/0x41f0
>  fib_table_insert+0x18f/0x1ac0
>  inet_rtm_newroute+0xfb/0x180
>  rtnetlink_rcv_msg+0x249/0x6a0
>  netlink_rcv_skb+0x247/0x350
>  rtnetlink_rcv+0x2a/0x40
>  netlink_unicast+0x481/0x690
>  netlink_sendmsg+0x8c1/0xb70
>  sock_sendmsg+0xba/0xf0
>  ___sys_sendmsg+0x6c3/0x890
>  __sys_sendmsg+0xd5/0x170
>  SyS_sendmsg+0x12/0x20
>  entry_SYSCALL_64_fastpath+0x23/0xc6
> Freed:
> PID = 1869
>  save_stack_trace+0x1b/0x20
>  save_stack+0x46/0xd0
>  kasan_slab_free+0x71/0xb0
>  kfree+0xe8/0x2e0
>  free_fib_info_rcu+0x39a/0x490
>  rcu_process_callbacks+0x9d2/0x1220
>  __do_softirq+0x286/0x87d
> Memory state around the buggy address:
>  ffff8803dd32e280: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff8803dd32e300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> >ffff8803dd32e380: fc fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb
>                        ^
>  ffff8803dd32e400: fb fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff8803dd32e480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> 
> -- [4]
> 
> (gdb) list *(ipv4_mtu+0x25d)
> 0xffffffff8285d5cd is in ipv4_mtu (./include/net/dst.h:176).
> 171    static inline u32
> 172    dst_metric_raw(const struct dst_entry *dst, const int metric)
> 173    {
> 174        u32 *p = DST_METRICS_PTR(dst);
> 175
> 176        return p[metric-1];
> 177    }
> 178
> 179    static inline u32
> 180    dst_metric(const struct dst_entry *dst, const int metric)

Thanks for the report !

This patch should solve this precise issue, but we need more work.

We need to audit all __sk_dst_get() and make sure they are inside an
rcu_read_lock()/rcu_read_unlock() section.

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 22548b5f05cbe5a655e0c53df2d31c5cc2e8a702..517963e1cb6eb9d70fcd71f44262813c3378759f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1459,7 +1459,7 @@ EXPORT_SYMBOL(tcp_sync_mss);
 unsigned int tcp_current_mss(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
-	const struct dst_entry *dst = __sk_dst_get(sk);
+	const struct dst_entry *dst;
 	u32 mss_now;
 	unsigned int header_len;
 	struct tcp_out_options opts;
@@ -1467,11 +1467,14 @@ unsigned int tcp_current_mss(struct sock *sk)
 
 	mss_now = tp->mss_cache;
 
+	rcu_read_lock();
+	dst = __sk_dst_get(sk);
 	if (dst) {
 		u32 mtu = dst_mtu(dst);
 		if (mtu != inet_csk(sk)->icsk_pmtu_cookie)
 			mss_now = tcp_sync_mss(sk, mtu);
 	}
+	rcu_read_unlock();
 
 	header_len = tcp_established_options(sk, NULL, &opts, &md5) +
 		     sizeof(struct tcphdr);
