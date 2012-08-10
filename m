From: David Miller <davem@davemloft.net>
Subject: Re: Latest commit from 08 Aug 2012 hang system after run Eclipse
 -> Eclipse update
Date: Fri, 10 Aug 2012 16:26:20 -0700 (PDT)
Message-ID: <20120810.162620.1616692329467396174.davem@davemloft.net>
References: <502411B0.4080305@winsoft.pl>
	<CA+55aFz3M1bJ7PobLHPJAceToJivmnoHfe-NYbYv6FyqPg9otA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kkolasa@winsoft.pl
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46556 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760402Ab2HJX0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 19:26:21 -0400
In-Reply-To: <CA+55aFz3M1bJ7PobLHPJAceToJivmnoHfe-NYbYv6FyqPg9otA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 10 Aug 2012 21:07:16 +0300

> ---------- Forwarded message ----------
> From: "Krzysztof Kolasa" <kkolasa@winsoft.pl>
> Date: Aug 9, 2012 10:38 PM
> Subject: Latest commit from 08 Aug 2012 hang system after run Eclipse ->
> Eclipse update
> To: <torvalds@linux-foundation.org>
> 
> Probably after this path ( networking fixes from David Miller )
> https://github.com/torvalds/**linux/commit/**f4ba394c1b02e7fc2179fda8d3941a*
> *5b3b65efb6<https://github.com/torvalds/linux/commit/f4ba394c1b02e7fc2179fda8d3941a5b3b65efb6>
> 
> java ( TCP ? ) crash system : run Eclipse, next Update Eclipse from menu ->
> kernel panic stop hardware
> 
> error screenshot : https://docs.google.com/open?**id=**
> 0B1LAMAFWTdeweUl0MjdHNFJpbk0<https://docs.google.com/open?id=0B1LAMAFWTdeweUl0MjdHNFJpbk0>

Fixed in the 'net' tree by commit:

====================
commit 63d02d157ec4124990258d66517b6c11fd6df0cf
Author: Eric Dumazet <edumazet@google.com>
Date:   Thu Aug 9 14:11:00 2012 +0000

    net: tcp: ipv6_mapped needs sk_rx_dst_set method
    
    commit 5d299f3d3c8a2fb (net: ipv6: fix TCP early demux) added a
    regression for ipv6_mapped case.
    
    [   67.422369] SELinux: initialized (dev autofs, type autofs), uses
    genfs_contexts
    [   67.449678] SELinux: initialized (dev autofs, type autofs), uses
    genfs_contexts
    [   92.631060] BUG: unable to handle kernel NULL pointer dereference at
    (null)
    [   92.631435] IP: [<          (null)>]           (null)
    [   92.631645] PGD 0
    [   92.631846] Oops: 0010 [#1] SMP
    [   92.632095] Modules linked in: autofs4 sunrpc ipv6 dm_mirror
    dm_region_hash dm_log dm_multipath dm_mod video sbs sbshc battery ac lp
    parport sg snd_hda_intel snd_hda_codec snd_seq_oss snd_seq_midi_event
    snd_seq snd_seq_device pcspkr snd_pcm_oss snd_mixer_oss snd_pcm
    snd_timer serio_raw button floppy snd i2c_i801 i2c_core soundcore
    snd_page_alloc shpchp ide_cd_mod cdrom microcode ehci_hcd ohci_hcd
    uhci_hcd
    [   92.634294] CPU 0
    [   92.634294] Pid: 4469, comm: sendmail Not tainted 3.6.0-rc1 #3
    [   92.634294] RIP: 0010:[<0000000000000000>]  [<          (null)>]
    (null)
    [   92.634294] RSP: 0018:ffff880245fc7cb0  EFLAGS: 00010282
    [   92.634294] RAX: ffffffffa01985f0 RBX: ffff88024827ad00 RCX:
    0000000000000000
    [   92.634294] RDX: 0000000000000218 RSI: ffff880254735380 RDI:
    ffff88024827ad00
    [   92.634294] RBP: ffff880245fc7cc8 R08: 0000000000000001 R09:
    0000000000000000
    [   92.634294] R10: 0000000000000000 R11: ffff880245fc7bf8 R12:
    ffff880254735380
    [   92.634294] R13: ffff880254735380 R14: 0000000000000000 R15:
    7fffffffffff0218
    [   92.634294] FS:  00007f4516ccd6f0(0000) GS:ffff880256600000(0000)
    knlGS:0000000000000000
    [   92.634294] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
    [   92.634294] CR2: 0000000000000000 CR3: 0000000245ed1000 CR4:
    00000000000007f0
    [   92.634294] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
    0000000000000000
    [   92.634294] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
    0000000000000400
    [   92.634294] Process sendmail (pid: 4469, threadinfo ffff880245fc6000,
    task ffff880254b8cac0)
    [   92.634294] Stack:
    [   92.634294]  ffffffff813837a7 ffff88024827ad00 ffff880254b6b0e8
    ffff880245fc7d68
    [   92.634294]  ffffffff81385083 00000000001d2680 ffff8802547353a8
    ffff880245fc7d18
    [   92.634294]  ffffffff8105903a ffff88024827ad60 0000000000000002
    00000000000000ff
    [   92.634294] Call Trace:
    [   92.634294]  [<ffffffff813837a7>] ? tcp_finish_connect+0x2c/0xfa
    [   92.634294]  [<ffffffff81385083>] tcp_rcv_state_process+0x2b6/0x9c6
    [   92.634294]  [<ffffffff8105903a>] ? sched_clock_cpu+0xc3/0xd1
    [   92.634294]  [<ffffffff81059073>] ? local_clock+0x2b/0x3c
    [   92.634294]  [<ffffffff8138caf3>] tcp_v4_do_rcv+0x63a/0x670
    [   92.634294]  [<ffffffff8133278e>] release_sock+0x128/0x1bd
    [   92.634294]  [<ffffffff8139f060>] __inet_stream_connect+0x1b1/0x352
    [   92.634294]  [<ffffffff813325f5>] ? lock_sock_nested+0x74/0x7f
    [   92.634294]  [<ffffffff8104b333>] ? wake_up_bit+0x25/0x25
    [   92.634294]  [<ffffffff813325f5>] ? lock_sock_nested+0x74/0x7f
    [   92.634294]  [<ffffffff8139f223>] ? inet_stream_connect+0x22/0x4b
    [   92.634294]  [<ffffffff8139f234>] inet_stream_connect+0x33/0x4b
    [   92.634294]  [<ffffffff8132e8cf>] sys_connect+0x78/0x9e
    [   92.634294]  [<ffffffff813fd407>] ? sysret_check+0x1b/0x56
    [   92.634294]  [<ffffffff81088503>] ? __audit_syscall_entry+0x195/0x1c8
    [   92.634294]  [<ffffffff811cc26e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
    [   92.634294]  [<ffffffff813fd3e2>] system_call_fastpath+0x16/0x1b
    [   92.634294] Code:  Bad RIP value.
    [   92.634294] RIP  [<          (null)>]           (null)
    [   92.634294]  RSP <ffff880245fc7cb0>
    [   92.634294] CR2: 0000000000000000
    [   92.648982] ---[ end trace 24e2bed94314c8d9 ]---
    [   92.649146] Kernel panic - not syncing: Fatal exception in interrupt
    
    Fix this using inet_sk_rx_dst_set(), and export this function in case
    IPv6 is modular.
    
    Reported-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/tcp.h b/include/net/tcp.h
index e19124b..1f000ff 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -464,6 +464,7 @@ extern int tcp_disconnect(struct sock *sk, int flags);
 void tcp_connect_init(struct sock *sk);
 void tcp_finish_connect(struct sock *sk, struct sk_buff *skb);
 int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size);
+void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb);
 
 /* From syncookies.c */
 extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 272241f..7678237 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1869,7 +1869,7 @@ static struct timewait_sock_ops tcp_timewait_sock_ops = {
 	.twsk_destructor= tcp_twsk_destructor,
 };
 
-static void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
+void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 
@@ -1877,6 +1877,7 @@ static void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
 	sk->sk_rx_dst = dst;
 	inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
 }
+EXPORT_SYMBOL(inet_sk_rx_dst_set);
 
 const struct inet_connection_sock_af_ops ipv4_specific = {
 	.queue_xmit	   = ip_queue_xmit,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5a439e9..bb9ce2b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1777,6 +1777,7 @@ static const struct inet_connection_sock_af_ops ipv6_mapped = {
 	.queue_xmit	   = ip_queue_xmit,
 	.send_check	   = tcp_v4_send_check,
 	.rebuild_header	   = inet_sk_rebuild_header,
+	.sk_rx_dst_set	   = inet_sk_rx_dst_set,
 	.conn_request	   = tcp_v6_conn_request,
 	.syn_recv_sock	   = tcp_v6_syn_recv_sock,
 	.net_header_len	   = sizeof(struct iphdr),
