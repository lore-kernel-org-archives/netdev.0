From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: ipv4_dst_destroy panic regression after 3.10.15
Date: Tue, 21 Jan 2014 22:02:43 -0800
Message-ID: <CAADnVQ+MNHFKmCSS7m42s7gz68sCwNUY4U571R5XVH0sU0=ffQ@mail.gmail.com>
References: <alpine.DEB.2.10.1401171720560.15759@dinf>
	<1390027758.31367.505.camel@edumazet-glaptop2.roam.corp.google.com>
	<1390028976.31367.512.camel@edumazet-glaptop2.roam.corp.google.com>
	<alpine.DEB.2.10.1401172313530.18419@dinf>
	<CAADnVQKQFQh2JewwmXWBkyB86rOJs1mXHrgECikaMxGqFW3axA@mail.gmail.com>
	<alpine.DEB.2.02.1401211735170.20572@dtop>
	<CAMEtUuzq+KhzZfxzAo=fgYr9umtQCPx-4Jp_twtrM-eh1Bv14w@mail.gmail.com>
	<alpine.DEB.2.02.1401212008010.20572@dtop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:63493 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbaAVGCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 01:02:44 -0500
In-Reply-To: <alpine.DEB.2.02.1401212008010.20572@dtop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 21, 2014 at 8:10 PM, dormando <dormando@rydia.net> wrote:
>
>
> On Tue, 21 Jan 2014, Alexei Starovoitov wrote:
>
>> On Tue, Jan 21, 2014 at 5:39 PM, dormando <dormando@rydia.net> wrote:
>> >
>> > > On Fri, Jan 17, 2014 at 11:16 PM, dormando <dormando@rydia.net> wrote:
>> > > >> On Fri, 2014-01-17 at 22:49 -0800, Eric Dumazet wrote:
>> > > >> > On Fri, 2014-01-17 at 17:25 -0800, dormando wrote:
>> > > >> > > Hi,
>> > > >> > >
>> > > >> > > Upgraded a few kernels to the latest 3.10 stable tree while tracking down
>> > > >> > > a rare kernel panic, seems to have introduced a much more frequent kernel
>> > > >> > > panic. Takes anywhere from 4 hours to 2 days to trigger:
>> > > >> > >
>> > > >> > > <4>[196727.311203] general protection fault: 0000 [#1] SMP
>> > > >> > > <4>[196727.311224] Modules linked in: xt_TEE xt_dscp xt_DSCP macvlan bridge coretemp crc32_pclmul ghash_clmulni_intel gpio_ich microcode
>> ipmi_watchdog ipmi_devintf sb_edac edac_core lpc_ich mfd_core tpm_tis tpm tpm_bios ipmi_si ipmi_msghandler isci igb libsas i2c_algo_bit ixgbe ptp
>> pps_core mdio
>> > > >> > > <4>[196727.311333] CPU: 17 PID: 0 Comm: swapper/17 Not tainted 3.10.26 #1
>> > > >> > > <4>[196727.311344] Hardware name: Supermicro X9DRi-LN4+/X9DR3-LN4+/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0 07/05/2013
>> > > >> > > <4>[196727.311364] task: ffff885e6f069700 ti: ffff885e6f072000 task.ti: ffff885e6f072000
>> > > >> > > <4>[196727.311377] RIP: 0010:[<ffffffff815f8c7f>]  [<ffffffff815f8c7f>] ipv4_dst_destroy+0x4f/0x80
>> > > >> > > <4>[196727.311399] RSP: 0018:ffff885effd23a70  EFLAGS: 00010282
>> > > >> > > <4>[196727.311409] RAX: dead000000200200 RBX: ffff8854c398ecc0 RCX: 0000000000000040
>> > > >> > > <4>[196727.311423] RDX: dead000000100100 RSI: dead000000100100 RDI: dead000000200200
>> > > >> > > <4>[196727.311437] RBP: ffff885effd23a80 R08: ffffffff815fd9e0 R09: ffff885d5a590800
>> > > >> > > <4>[196727.311451] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
>> > > >> > > <4>[196727.311464] R13: ffffffff81c8c280 R14: 0000000000000000 R15: ffff880e85ee16ce
>> > > >> > > <4>[196727.311510] FS:  0000000000000000(0000) GS:ffff885effd20000(0000) knlGS:0000000000000000
>> > > >> > > <4>[196727.311554] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> > > >> > > <4>[196727.311581] CR2: 00007a46751eb000 CR3: 0000005e65688000 CR4: 00000000000407e0
>> > > >> > > <4>[196727.311625] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> > > >> > > <4>[196727.311669] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> > > >> > > <4>[196727.311713] Stack:
>> > > >> > > <4>[196727.311733]  ffff8854c398ecc0 ffff8854c398ecc0 ffff885effd23ab0 ffffffff815b7f42
>> > > >> > > <4>[196727.311784]  ffff88be6595bc00 ffff8854c398ecc0 0000000000000000 ffff8854c398ecc0
>> > > >> > > <4>[196727.311834]  ffff885effd23ad0 ffffffff815b86c6 ffff885d5a590800 ffff8816827821c0
>> > > >> > > <4>[196727.311885] Call Trace:
>> > > >> > > <4>[196727.311907]  <IRQ>
>> > > >> > > <4>[196727.311912]  [<ffffffff815b7f42>] dst_destroy+0x32/0xe0
>> > > >> > > <4>[196727.311959]  [<ffffffff815b86c6>] dst_release+0x56/0x80
>> > > >> > > <4>[196727.311986]  [<ffffffff81620bd5>] tcp_v4_do_rcv+0x2a5/0x4a0
>> > > >> > > <4>[196727.312013]  [<ffffffff81622b5a>] tcp_v4_rcv+0x7da/0x820
>> > > >> > > <4>[196727.312041]  [<ffffffff815fd9e0>] ? ip_rcv_finish+0x360/0x360
>> > > >> > > <4>[196727.312070]  [<ffffffff815de02d>] ? nf_hook_slow+0x7d/0x150
>> > > >> > > <4>[196727.312097]  [<ffffffff815fd9e0>] ? ip_rcv_finish+0x360/0x360
>> > > >> > > <4>[196727.312125]  [<ffffffff815fda92>] ip_local_deliver_finish+0xb2/0x230
>> > > >> > > <4>[196727.312154]  [<ffffffff815fdd9a>] ip_local_deliver+0x4a/0x90
>> > > >> > > <4>[196727.312183]  [<ffffffff815fd799>] ip_rcv_finish+0x119/0x360
>> > > >> > > <4>[196727.312212]  [<ffffffff815fe00b>] ip_rcv+0x22b/0x340
>> > > >> > > <4>[196727.312242]  [<ffffffffa0339680>] ? macvlan_broadcast+0x160/0x160 [macvlan]
>> > > >> > > <4>[196727.312275]  [<ffffffff815b0c62>] __netif_receive_skb_core+0x512/0x640
>> > > >> > > <4>[196727.312308]  [<ffffffff811427fb>] ? kmem_cache_alloc+0x13b/0x150
>> > > >> > > <4>[196727.312338]  [<ffffffff815b0db1>] __netif_receive_skb+0x21/0x70
>> > > >> > > <4>[196727.312368]  [<ffffffff815b0fa1>] netif_receive_skb+0x31/0xa0
>> > > >> > > <4>[196727.312397]  [<ffffffff815b1ae8>] napi_gro_receive+0xe8/0x140
>> > > >> > > <4>[196727.312433]  [<ffffffffa00274f1>] ixgbe_poll+0x551/0x11f0 [ixgbe]
>> > > >> > > <4>[196727.312463]  [<ffffffff815fe00b>] ? ip_rcv+0x22b/0x340
>> > > >> > > <4>[196727.312491]  [<ffffffff815b1691>] net_rx_action+0x111/0x210
>> > > >> > > <4>[196727.312521]  [<ffffffff815b0db1>] ? __netif_receive_skb+0x21/0x70
>> > > >> > > <4>[196727.312552]  [<ffffffff810519d0>] __do_softirq+0xd0/0x270
>> > > >> > > <4>[196727.312583]  [<ffffffff816cef3c>] call_softirq+0x1c/0x30
>> > > >> > > <4>[196727.312613]  [<ffffffff81004205>] do_softirq+0x55/0x90
>> > > >> > > <4>[196727.312640]  [<ffffffff81051c85>] irq_exit+0x55/0x60
>> > > >> > > <4>[196727.312668]  [<ffffffff816cf5c3>] do_IRQ+0x63/0xe0
>> > > >> > > <4>[196727.312696]  [<ffffffff816c5aaa>] common_interrupt+0x6a/0x6a
>> > > >> > > <4>[196727.312722]  <EOI>
>> > > >> > > <4>[196727.312727]  [<ffffffff8100a150>] ? default_idle+0x20/0xe0
>> > > >> > > <4>[196727.312775]  [<ffffffff8100a8ff>] arch_cpu_idle+0xf/0x20
>> > > >> > > <4>[196727.312803]  [<ffffffff8108d330>] cpu_startup_entry+0xc0/0x270
>> > > >> > > <4>[196727.312833]  [<ffffffff816b276e>] start_secondary+0x1f9/0x200
>> > > >> > > <4>[196727.312860] Code: 4a 9f e9 81 e8 13 cb 0c 00 48 8b 93 b0 00 00 00 48 bf 00 02 20 00 00 00 ad de 48 8b 83 b8 00 00 00 48 be 00 01
>> 10 00 00 00 ad de <48> 89 42 08 48 89 10 48 89 bb b8 00 00 00 48 c7 c7 4a 9f e9 81
>> > > >> > > <1>[196727.313071] RIP  [<ffffffff815f8c7f>] ipv4_dst_destroy+0x4f/0x80
>> > > >> > > <4>[196727.313100]  RSP <ffff885effd23a70>
>> > > >> > > <4>[196727.313377] ---[ end trace 64b3f14fae0f2e29 ]---
>> > > >> > > <0>[196727.380908] Kernel panic - not syncing: Fatal exception in interrupt
>> > > >> > >
>> > > >> > >
>> > > >> > > ... bisecting it's going to be a pain... I tried eyeballing the diffs and
>> > > >> > > am trying a revert or two.
>> > > >> > >
>> > > >> > > We've hit it in .25, .26 so far. I have .27 running but not sure if it
>> > > >> > > crashed, so the change exists between .15 and .25.
>> > > >> >
>> > > >> > Please try following fix, thanks for the report !
>> > > >> >
>> > > >> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> > > >> > index 25071b48921c..78a50a22298a 100644
>> > > >> > --- a/net/ipv4/route.c
>> > > >> > +++ b/net/ipv4/route.c
>> > > >> > @@ -1333,7 +1333,7 @@ static void ipv4_dst_destroy(struct dst_entry
>> > > >> > *dst)
>> > > >> >
>> > > >> >     if (!list_empty(&rt->rt_uncached)) {
>> > > >> >             spin_lock_bh(&rt_uncached_lock);
>> > > >> > -           list_del(&rt->rt_uncached);
>> > > >> > +           list_del_init(&rt->rt_uncached);
>> > > >> >             spin_unlock_bh(&rt_uncached_lock);
>> > > >> >     }
>> > > >> >  }
>> > > >> >
>> > > >>
>> > > >> Problem could come from this commit, in linux 3.10.23,
>> > > >> you also could try to revert it
>> > > >>
>> > > >> commit 62713c4b6bc10c2d082ee1540e11b01a2b2162ab
>> > > >> Author: Alexei Starovoitov <ast@plumgrid.com>
>> > > >> Date:   Tue Nov 19 19:12:34 2013 -0800
>> > > >>
>> > > >>     ipv4: fix race in concurrent ip_route_input_slow()
>> > > >>
>> > > >>     [ Upstream commit dcdfdf56b4a6c9437fc37dbc9cee94a788f9b0c4 ]
>> > > >>
>> > > >>     CPUs can ask for local route via ip_route_input_noref() concurrently.
>> > > >>     if nh_rth_input is not cached yet, CPUs will proceed to allocate
>> > > >>     equivalent DSTs on 'lo' and then will try to cache them in nh_rth_input
>> > > >>     via rt_cache_route()
>> > > >>     Most of the time they succeed, but on occasion the following two lines:
>> > > >>         orig = *p;
>> > > >>         prev = cmpxchg(p, orig, rt);
>> > > >>     in rt_cache_route() do race and one of the cpus fails to complete cmpxchg.
>> > > >>     But ip_route_input_slow() doesn't check the return code of rt_cache_route(),
>> > > >>     so dst is leaking. dst_destroy() is never called and 'lo' device
>> > > >>     refcnt doesn't go to zero, which can be seen in the logs as:
>> > > >>         unregister_netdevice: waiting for lo to become free. Usage count = 1
>> > > >>     Adding mdelay() between above two lines makes it easily reproducible.
>> > > >>     Fix it similar to nh_pcpu_rth_output case.
>> > > >>
>> > > >>     Fixes: d2d68ba9fe8b ("ipv4: Cache input routes in fib_info nexthops.")
>> > > >>     Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> > > >>     Signed-off-by: David S. Miller <davem@davemloft.net>
>> > > >>     Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> > > >>
>> > > >
>> > > > Heh. I spent an hour squinting at the difflog from .15 to .25 and this was
>> > > > my best guess. I have a kernel running in production with only this
>> > > > reverted as of ~5 hours ago. Won't know if it helps for a day or two.
>> > > >
>> > > > I'm building a kernel now with your route patch, but 62713c4 *not*
>> > > > reverted, which I can throw on a different machine. Does this sound like a
>> > > > good idea?
>> > >
>> > > the traces of your crash don't look similar to dst leak that was fixed by
>> > > commit 62713c4...
>> > >
>> > > To trigger the 'fix' logic of the 62713c4 add the following diff:
>> > > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> > > index f6c6ab1..8972676 100644
>> > > --- a/net/ipv4/route.c
>> > > +++ b/net/ipv4/route.c
>> > > @@ -1259,7 +1259,7 @@ static bool rt_cache_route(struct fib_nh *nh,
>> > > struct rtable *rt)
>> > >                 p = (struct rtable **)__this_cpu_ptr(nh->nh_pcpu_rth_output);
>> > >         }
>> > >         orig = *p;
>> > > -
>> > > +       mdelay(100);
>> > >         prev = cmpxchg(p, orig, rt);
>> > >         if (prev == orig) {
>> > >                 if (orig)
>> > >
>> > > I've been running with it for a day without issues.
>> > > Note that it will stress both 'input' and 'output' ways of adding dsts to
>> > > rt_uncached list...
>> > > and 'output' was there for ages.
>> > >
>> > > If mdelay() helps to reproduce it in minutes instead of days
>> > > then we're on the right path.
>> > > Could you share details of your workload?
>> > > In our case it was a lot of namespaces with a ton of processes
>> > > talking to each other, forcefully killed and restarted.
>> > > Do you see the same crash in the latest tree?
>> > >
>> > > PS sorry for double posts. netdev email bounced few times for me...
>> > >
>> >
>> > So with 62713c4 reverted on top of 3.10.27 (no other new patches), both of
>> > my machines have survived. One four days, another two days. They'd barely
>> > make it a day before.
>> >
>> > So this patch is introducing a new problem. Weakening the dst reference
>> > too much in a false positive case?
>> >
>> > I'm not entirely sure if the mdelay(100) thing will help much. I can try
>> > it but it's kind of obnoxious to reboot these machines (far away, ipmi
>> > only) too often. Unless you folks have any new ideas before I go off and
>> > do that?
>>
>> mdelay() won't fix things, but it will help debugging. Can you try it on just one machine? It should fail within minutes.
>>
>> Only afterwards we can try alternative fix like:
>> @@ -1722,8 +1722,8 @@ local_input:
>>         }
>>         if (do_cache) {
>>                 if (unlikely(!rt_cache_route(&FIB_RES_NH(res), rth))) {
>> -                       rth->dst.flags |= DST_NOCACHE;
>> -                       rt_add_uncached_list(rth);
>> +                       rt_free(rth);
>> +                       goto local_input;
>>                 }
>>         }
>>         skb_dst_set(skb, &rth->dst);
>>
>>
>>
>
> It might take a day or three to find a good time to do it. I don't have
> access to reboot the machines myself. Oh how I wish things broke in the
> lab more often :/
>
> To be clear, I add your old patch back in + the mdelay. If that fails
> within a few minutes, I add this new patch instead of your old one?

yes. vanilla 3.10.23+ and mdelay() will be triggering rt_add_uncached path.
If that fails quickly, I think we better debug it further to really understand
what's going on. Alternative fix may workaround the problem,
since it will be freeing dst immediately if it fails to be cached and retrying
allocation and caching again, but that would mean that double free problem
is simply hidden instead of fixed.
I would add tracing of rth free/alloc.
If mdelay() makes it fail quickly, the trace won't be too long.
config_debug_kmemleak may be helpful (though unlikely in this situation).
since your crash traces look like double free, we can enable config_slub_debug
and call verify_mem_not_deleted() from dst_destroy()
