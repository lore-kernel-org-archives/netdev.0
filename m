From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [WARNING] stmmac: refcount_t: saturated; leaking memory
Date: Mon, 21 Aug 2017 11:29:25 +0200
Message-ID: <20170821092925.GB9458@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

I got on all my stmmac boards the following warning:

[12605.062840] ------------[ cut here ]------------
[12605.062956] WARNING: CPU: 0 PID: 15637 at /linux-next/lib/refcount.c:77 refcount_add_not_zero+0xa8/0xb8
[12605.062972] refcount_t: saturated; leaking memory.
[12605.062987] Modules linked in: iptable_filter ip_tables x_tables nfnetlink_log nfnetlink sun8i_ce crypto_engine
[12605.063122] CPU: 0 PID: 15637 Comm: kworker/0:1 Not tainted 4.13.0-rc5-next-20170817+ #403
[12605.063136] Hardware name: Allwinner sun8i Family
[12605.063161] Workqueue: rpciod rpc_async_schedule
[12605.063186] Backtrace: 
[12605.063222] [<c010cc30>] (dump_backtrace) from [<c010cf2c>] (show_stack+0x18/0x1c)
[12605.063241]  r7:c0c51700 r6:00000000 r5:600d0013 r4:c0c51700
[12605.063262] [<c010cf14>] (show_stack) from [<c06ea23c>] (dump_stack+0xac/0xd8)
[12605.063283] [<c06ea190>] (dump_stack) from [<c0125114>] (__warn+0xec/0x104)
[12605.063304]  r10:c064c3c8 r9:c0400ea8 r8:0000004d r7:00000009 r6:c0987468 r5:00000000
[12605.063319]  r4:ed8cd7b0 r3:00040d00
[12605.063339] [<c0125028>] (__warn) from [<c012516c>] (warn_slowpath_fmt+0x40/0x48)
[12605.063359]  r9:ee2c5bb8 r8:ebf8e6c0 r7:c064c3c8 r6:ebf8ee40 r5:0a028725 r4:c0987440
[12605.063379] [<c0125130>] (warn_slowpath_fmt) from [<c0400ea8>] (refcount_add_not_zero+0xa8/0xb8)
[12605.063395]  r3:c0c5262c r2:c0987440
[12605.063408]  r4:00000001
[12605.063427] [<c0400e00>] (refcount_add_not_zero) from [<c0400ec8>] (refcount_add+0x10/0x50)
[12605.063443]  r5:0a028725 r4:ee5f4e80
[12605.063465] [<c0400eb8>] (refcount_add) from [<c065deec>] (tcp_gso_segment+0x448/0x47c)
[12605.063486] [<c065daa4>] (tcp_gso_segment) from [<c065df6c>] (tcp4_gso_segment+0x4c/0xac)
[12605.063506]  r10:c08744bc r9:0000005e r8:00000000 r7:00000020 r6:00004833 r5:0000006c
[12605.063520]  r4:ee2c5bb8
[12605.063541] [<c065df20>] (tcp4_gso_segment) from [<c067202c>] (inet_gso_segment+0x1a0/0x330)
[12605.063559]  r7:00000000 r6:0000184e r5:0000006c r4:ee2c5bb8
[12605.063582] [<c0671e8c>] (inet_gso_segment) from [<c05e4fa0>] (skb_mac_gso_segment+0xe8/0x1f4)
[12605.063602]  r10:ee842850 r9:ee9e8000 r8:c0671e8c r7:ee2c5bb8 r6:00000008 r5:00000020
[12605.063616]  r4:00004833
[12605.063638] [<c05e4eb8>] (skb_mac_gso_segment) from [<c05e517c>] (__skb_gso_segment+0xd0/0x198)
[12605.063657]  r8:00000000 r7:00000020 r6:00004833 r5:00000001 r4:ee2c5bb8
[12605.063679] [<c05e50ac>] (__skb_gso_segment) from [<c05e5700>] (validate_xmit_skb+0x124/0x2e4)
[12605.063698]  r9:ee9e8000 r8:00000000 r7:00000020 r6:00004833 r5:00000000 r4:ee2c5bb8
[12605.063720] [<c05e55dc>] (validate_xmit_skb) from [<c05e58f8>] (validate_xmit_skb_list+0x38/0x68)
[12605.063740]  r10:ee842850 r9:00000000 r8:00000000 r7:ee9e8000 r6:00000000 r5:ee2c5bb8
[12605.063754]  r4:00000000
[12605.063777] [<c05e58c0>] (validate_xmit_skb_list) from [<c06127d4>] (sch_direct_xmit+0x154/0x19c)
[12605.063797]  r9:00000000 r8:00000001 r7:ee9e8000 r6:ee91d800 r5:ee2c5bb8 r4:ee842800
[12605.063817] [<c0612680>] (sch_direct_xmit) from [<c05e6148>] (__dev_queue_xmit+0x614/0x7ec)
[12605.063836]  r8:013ba711 r7:00000000 r6:00000bd4 r5:ee842800 r4:00000001
[12605.063858] [<c05e5b34>] (__dev_queue_xmit) from [<c05e6334>] (dev_queue_xmit+0x14/0x18)
[12605.063877]  r10:00000000 r9:0000000e r8:ee2c5bb8 r7:ee84210c r6:00000000 r5:ee842144
[12605.063891]  r4:ee842000
[12605.063913] [<c05e6320>] (dev_queue_xmit) from [<c06303c0>] (ip_finish_output2+0x2e8/0x758)
[12605.063933] [<c06300d8>] (ip_finish_output2) from [<c0632388>] (ip_finish_output+0x238/0x348)
[12605.063953]  r10:ee9e8000 r9:00000001 r8:000005dc r7:00000000 r6:c0c4a580 r5:ee336580
[12605.063966]  r4:ee2c5bb8
[12605.063985] [<c0632150>] (ip_finish_output) from [<c063382c>] (ip_output+0x10c/0x30c)
[12605.064005]  r10:ee9e8000 r9:00000000 r8:00003eb6 r7:00000000 r6:00291fb3 r5:ee2c5bb8
[12605.064018]  r4:ef7b1288
[12605.064037] [<c0633720>] (ip_output) from [<c06327b4>] (ip_local_out+0x48/0x84)
[12605.064057]  r10:ee27f900 r9:00026900 r8:00026900 r7:00000000 r6:ee336580 r5:c0c4a580
[12605.064070]  r4:ee2c5bb8
[12605.064089] [<c063276c>] (ip_local_out) from [<c0632bd0>] (ip_queue_xmit+0x1e8/0x634)
[12605.064107]  r7:00000000 r6:ee3368b0 r5:ee336580 r4:ee2c5bb8
[12605.064129] [<c06329e8>] (ip_queue_xmit) from [<c064ddb4>] (tcp_transmit_skb+0x444/0x8e4)
[12605.064149]  r10:00000000 r9:00026900 r8:00026900 r7:00000000 r6:00000000 r5:ee2c5bb8
[12605.064163]  r4:ee336580
[12605.064184] [<c064d970>] (tcp_transmit_skb) from [<c064e470>] (tcp_write_xmit+0x21c/0xfe0)
[12605.064204]  r9:000005a8 r8:0a02817d r7:00000000 r6:ee2c5b00 r5:00000b50 r4:ee336580
[12605.064225] [<c064e254>] (tcp_write_xmit) from [<c064f270>] (__tcp_push_pending_frames+0x3c/0xa4)
[12605.064245]  r10:000005a8 r9:00000000 r8:00000f03 r7:0a02817d r6:00008000 r5:ee2c5b00
[12605.064259]  r4:ee336580
[12605.064280] [<c064f234>] (__tcp_push_pending_frames) from [<c063c388>] (tcp_push+0xcc/0x138)
[12605.064294]  r4:ee336580
[12605.064314] [<c063c2bc>] (tcp_push) from [<c063ffcc>] (do_tcp_sendpages+0x568/0x5b0)
[12605.064331]  r7:0000c040 r6:00000f03 r5:ee2c5b00 r4:ee336580
[12605.064351] [<c063fa64>] (do_tcp_sendpages) from [<c06400c0>] (tcp_sendpage_locked+0xac/0xc8)
[12605.064371]  r10:ed8cddf4 r9:00000f03 r8:00000f03 r7:00000000 r6:00000008 r5:eff47880
[12605.064385]  r4:ee336580
[12605.064405] [<c0640014>] (tcp_sendpage_locked) from [<c0640120>] (tcp_sendpage+0x44/0x5c)
[12605.064423]  r7:00000000 r6:eff47880 r5:0000c040 r4:ee336580
[12605.064443] [<c06400dc>] (tcp_sendpage) from [<c0671aec>] (inet_sendpage+0x6c/0x244)
[12605.064461]  r8:00000000 r7:eff47880 r6:eec5b980 r5:c06400dc r4:ee336580
[12605.064482] [<c0671a80>] (inet_sendpage) from [<c06c3df0>] (xs_sendpages+0x1e4/0x230)
[12605.064502]  r10:ed8cddf4 r9:00001000 r8:ee1893bc r7:eec5b980 r6:ee11d304 r5:00000000
[12605.064515]  r4:00000f03
[12605.064535] [<c06c3c0c>] (xs_sendpages) from [<c06c40b0>] (xs_tcp_send_request+0xa0/0x198)
[12605.064555]  r10:c09c77c4 r9:ee189200 r8:c0c52990 r7:ed807000 r6:ee11d304 r5:00000000
[12605.064568]  r4:ee11d300
[12605.064588] [<c06c4010>] (xs_tcp_send_request) from [<c06c12dc>] (xprt_transmit+0x4c/0x22c)
[12605.064607]  r10:00000001 r9:00000000 r8:ed8073a4 r7:ee11d374 r6:ee189200 r5:ee11d300
[12605.064621]  r4:ed807000
[12605.064643] [<c06c1290>] (xprt_transmit) from [<c06be528>] (call_transmit+0x168/0x200)
[12605.064662]  r9:00000000 r8:1462b931 r7:ee11d300 r6:00004001 r5:ee11d300 r4:ee189200
[12605.064683] [<c06be3c0>] (call_transmit) from [<c06c63e4>] (__rpc_execute+0x60/0x27c)
[12605.064702]  r8:c06c5d28 r7:c06c5994 r6:00000001 r5:00000000 r4:ee189200
[12605.064722] [<c06c6384>] (__rpc_execute) from [<c06c6614>] (rpc_async_schedule+0x14/0x18)
[12605.064742]  r10:00000001 r9:00000000 r8:00000000 r7:ef7b1700 r6:ef7ac0c0 r5:ee694700
[12605.064756]  r4:ee189224
[12605.064777] [<c06c6600>] (rpc_async_schedule) from [<c014126c>] (process_one_work+0x25c/0x524)
[12605.064796] [<c0141010>] (process_one_work) from [<c01421e4>] (worker_thread+0x58/0x588)
[12605.064816]  r10:ee694700 r9:ed8cc000 r8:ef7ac0f8 r7:c0c04d00 r6:00000008 r5:ee694718
[12605.064830]  r4:ef7ac0c0
[12605.064850] [<c014218c>] (worker_thread) from [<c0148514>] (kthread+0x174/0x1b0)
[12605.064870]  r10:ee694700 r9:ee627da8 r8:ee510480 r7:ed8cc000 r6:ef3e5480 r5:00000000
[12605.064884]  r4:ee510400
[12605.064906] [<c01483a0>] (kthread) from [<c0108238>] (ret_from_fork+0x14/0x3c)
[12605.064925]  r10:00000000 r9:00000000 r8:00000000 r7:00000000 r6:00000000 r5:c01483a0
[12605.064939]  r4:ef3e5480
[12605.064954] ---[ end trace c8c0d6caaf57fa10 ]---

So basicly it means that stmmac leaks skb ?

Thanks
Regards
