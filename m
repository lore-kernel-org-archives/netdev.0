From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled
 with CONFIG_IPV6_ROUTER_PREF
Date: Wed, 10 Jul 2013 11:28:57 +0200
Message-ID: <51DD2959.9060206@6wind.com>
References: <20130707173031.GC9625@order.stressinduktion.org> <20130709215701.GD9763@order.stressinduktion.org> <51DD1352.8000705@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:46925 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087Ab3GJJ3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 05:29:01 -0400
Received: by mail-wi0-f182.google.com with SMTP id m6so6114778wiv.9
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 02:29:00 -0700 (PDT)
In-Reply-To: <51DD1352.8000705@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/07/2013 09:54, Nicolas Dichtel a =C3=A9crit :
> Le 09/07/2013 23:57, Hannes Frederic Sowa a =C3=A9crit :
>> Hello Nicolas!
>>
>> I am currently trying to fix the nexthop selection for kernels compi=
led
>> without support for CONFIG_IPV6_ROUTER_PREF. I attached my current p=
atch
>> below. While testing I got the following kernel panic in ecmp code:
>>
>> [   80.144667] ------------[ cut here ]------------
>> [   80.145172] kernel BUG at net/ipv6/ip6_fib.c:733!
>> [   80.145172] invalid opcode: 0000 [#1] SMP
>> [   80.145172] Modules linked in: 8021q nf_conntrack_netbios_ns
>> nf_conntrack_broadcast ipt_MASQUERADE ip6table_mangle ip6t_REJECT
>> nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat ipta=
ble_mangle
>> nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_f=
ilter
>> ebtables ip6table_filter ip6_tables snd_hda_intel snd_hda_codec snd_=
hwdep
>> snd_seq snd_seq_device snd_pcm snd_page_alloc snd_timer virtio_ballo=
on snd
>> soundcore i2c_piix4 i2c_core virtio_net virtio_blk
>> [   80.145172] CPU: 1 PID: 786 Comm: ping6 Not tainted 3.10.0+ #118
>> [   80.145172] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>> [   80.145172] task: ffff880117fa0000 ti: ffff880118770000 task.ti:
>> ffff880118770000
>> [   80.145172] RIP: 0010:[<ffffffff815f3b5d>]  [<ffffffff815f3b5d>]
>> fib6_add+0x75d/0x830
>> [   80.145172] RSP: 0018:ffff880118771798  EFLAGS: 00010202
>> [   80.145172] RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff=
88011350e480
>> [   80.145172] RDX: ffff88011350e238 RSI: 0000000000000004 RDI: ffff=
88011350f738
>> [   80.145172] RBP: ffff880118771848 R08: ffff880117903280 R09: 0000=
000000000001
>> [   80.145172] R10: 0000000000000000 R11: 0000000000000000 R12: ffff=
88011350f680
>> [   80.145172] R13: ffff880117903280 R14: ffff880118771890 R15: ffff=
88011350ef90
>> [   80.145172] FS:  00007f02b5127740(0000) GS:ffff88011fd00000(0000)
>> knlGS:0000000000000000
>> [   80.145172] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [   80.145172] CR2: 00007f981322a000 CR3: 00000001181b1000 CR4: 0000=
0000000006e0
>> [   80.145172] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000=
000000000000
>> [   80.145172] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000=
000000000400
>> [   80.145172] Stack:
>> [   80.145172]  0000000000000001 ffff880100000000 ffff880100000000
>> ffff880117903280
>> [   80.145172]  0000000000000000 ffff880119a4cf00 0000000000000400
>> 00000000000007fa
>> [   80.145172]  0000000000000000 0000000000000000 0000000000000000
>> ffff88011350f680
>> [   80.145172] Call Trace:
>> [   80.145172]  [<ffffffff815eeceb>] ? rt6_bind_peer+0x4b/0x90
>> [   80.145172]  [<ffffffff815ed985>] __ip6_ins_rt+0x45/0x70
>> [   80.145172]  [<ffffffff815eee35>] ip6_ins_rt+0x35/0x40
>> [   80.145172]  [<ffffffff815ef1e4>] ip6_pol_route.isra.44+0x3a4/0x4=
b0
>> [   80.145172]  [<ffffffff815ef34a>] ip6_pol_route_output+0x2a/0x30
>> [   80.145172]  [<ffffffff81616077>] fib6_rule_action+0xd7/0x210
>> [   80.145172]  [<ffffffff815ef320>] ? ip6_pol_route_input+0x30/0x30
>> [   80.145172]  [<ffffffff81553026>] fib_rules_lookup+0xc6/0x140
>> [   80.145172]  [<ffffffff81616374>] fib6_rule_lookup+0x44/0x80
>> [   80.145172]  [<ffffffff815ef320>] ? ip6_pol_route_input+0x30/0x30
>> [   80.145172]  [<ffffffff815edea3>] ip6_route_output+0x73/0xb0
>> [   80.145172]  [<ffffffff815dfdf3>] ip6_dst_lookup_tail+0x2c3/0x2e0
>> [   80.145172]  [<ffffffff813007b1>] ? list_del+0x11/0x40
>> [   80.145172]  [<ffffffff81082a4c>] ? remove_wait_queue+0x3c/0x50
>> [   80.145172]  [<ffffffff815dfe4d>] ip6_dst_lookup_flow+0x3d/0xa0
>> [   80.145172]  [<ffffffff815fda77>] rawv6_sendmsg+0x267/0xc20
>> [   80.145172]  [<ffffffff815a8a83>] inet_sendmsg+0x63/0xb0
>> [   80.145172]  [<ffffffff8128eb93>] ? selinux_socket_sendmsg+0x23/0=
x30
>> [   80.145172]  [<ffffffff815218d6>] sock_sendmsg+0xa6/0xd0
>> [   80.145172]  [<ffffffff81524a68>] SYSC_sendto+0x128/0x180
>> [   80.145172]  [<ffffffff8109825c>] ? update_curr+0xec/0x170
>> [   80.145172]  [<ffffffff81041d09>] ? kvm_clock_get_cycles+0x9/0x10
>> [   80.145172]  [<ffffffff810afd1e>] ? __getnstimeofday+0x3e/0xd0
>> [   80.145172]  [<ffffffff8152509e>] SyS_sendto+0xe/0x10
>> [   80.145172]  [<ffffffff8164efd9>] system_call_fastpath+0x16/0x1b
>> [   80.145172] Code: fe ff ff 41 f6 45 2a 06 0f 85 ca fe ff ff 49 8b=
 7e 08 4c
>> 89 ee e8 94 ef ff ff e9 b9 fe ff ff 48 8b 82 28 05 00 00 e9 01 ff ff=
 ff <0f>
>> 0b 49 8b 54 24 30 0d 00 00 40 00 89 83 14 01 00 00 48 89 53
>> [   80.145172] RIP  [<ffffffff815f3b5d>] fib6_add+0x75d/0x830
>> [   80.145172]  RSP <ffff880118771798>
>> [   80.387413] ---[ end trace 02f20b7a8b81ed95 ]---
>> [   80.390154] Kernel panic - not syncing: Fatal exception in interr=
upt
>>
>> The relevant code is:
>>
>>      725                 /* For each sibling in the list, increment =
the
>> counter of
>>      726                  * siblings. BUG() if counters does not mat=
ch, list
>> of siblings
>>      727                  * is broken!
>>      728                  */
>>      729                 rt6i_nsiblings =3D 0;
>>      730                 list_for_each_entry_safe(sibling, temp_sibl=
ing,
>>      731                                          &rt->rt6i_siblings=
,
>> rt6i_siblings) {
>>      732                         sibling->rt6i_nsiblings++;
>>      733                         BUG_ON(sibling->rt6i_nsiblings !=3D
>> rt->rt6i_nsiblings);
>>      734                         rt6i_nsiblings++;
>>      735                 }
>>      736                 BUG_ON(rt6i_nsiblings !=3D rt->rt6i_nsiblin=
gs);
>>      737         }
>>
>> Currently, I don't know if I my patch is to blame or something in th=
e ecmp logic.
>>
>> Another thing I just noticed is:
>>
>>     1240         /* Remove this entry from other siblings */
>>     1241         if (rt->rt6i_nsiblings) {
>>     1242                 struct rt6_info *sibling, *next_sibling;
>>     1243
>>     1244                 list_for_each_entry_safe(sibling, next_sibl=
ing,
>>     1245                                          &rt->rt6i_siblings=
,
>> rt6i_siblings)
>>     1246                         sibling->rt6i_nsiblings--;
>>     1247                 rt->rt6i_nsiblings =3D 0;
>>     1248                 list_del_init(&rt->rt6i_siblings);
>>     1249         }
>>
>> Are we sure we decrement all sibling's rt6i_nsiblings? Shouldn't we
>> start iterating from fn->leaf? But this does not seem to cause it,
>> because my trace does not report any calls to fib6_del_route.
> Note sure to follow you, but all siblings are listed in rt6i_siblings=
, so it
> must be enough.
>
>>
>> You could try reproduce it by having an interface autoconfigured wit=
h
>> a default router with NUD_VALID neighbour. I then added an unused vl=
an
>> interface (vid 100 in my case) and added the following ip addresses:
>>
>> ip -6 a a 2001:ffff::1/64 dev eth0.100
>> ip -6 r a 2000::/3 nexthop via 2001:ffff::30 nexthop via 2001:ffff::=
31 nexthop
>> via 2001:ffff::32 nexthop via 2001:ffff::33
>>
>> (all nexthops should not be reachable)
>>
>> After starting a ping6 2000::1 the box should panic soon, after the
>> first nexthop entry times out.
>>
>> Perhaps you could give me a hint?
> I will run some tests with your patch. Will see.
I don't reproduce this panic.

Maybe you can try to revert this patch:
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/n=
et/ipv6/route.c?id=3D52bd4c0c1551daa2efa7bb9e01a2f4ea6d1311bb


Regards,
Nicolas

>
> I assume you didn't reproduce this without your patch.
>
>
> Regards,
> Nicolas
>
>>
>> Thanks a lot,
>>
>>    Hannes
>>
>>
>> [PATCH RFC] ipv6: fix route selection if kernel not compiled with
>> CONFIG_IPV6_ROUTER_PREF
>>
>> This is a follow-up patch to 3630d40067a21d4dfbadc6002bb469ce26ac5d5=
2
>> ("ipv6: rt6_check_neigh should successfully verify neigh if no NUD
>> information are available").
>>
>> Since the removal of rt->n in rt6_info we can end up with a dst =3D=3D
>> NULL in rt6_check_neigh. In case the kernel is not compiled with
>> CONFIG_IPV6_ROUTER_PREF we should also select a route with unkown
>> NUD state but we must not avoid doing round robin selection on route=
s
>> with the same target. So introduce and pass down a boolean ``do_rr''=
 to
>> indicate when we should update rt->rr_ptr. As soon as no route is va=
lid
>> we do backtracking and do a lookup on a higher level in the fib trie=
=2E
>>
>> To hold correct state on the NUD selection we need to create a neigh=
bour
>> entry as soon as we tried to validate a nexthop.
>>
>> I changed the return value of rt6_check_neigh to:
>>     1 in case of the dst entry validated
>>    -1 in case of we had no dst_entry and we need to do rr now
>>    -2 in case a we had a dst_entry and it did not validate
>>
>> In case of CONFIG_IPV6_ROUTER_PREF, rt6_probe does not allocate an
>> neighbour entry (!CONFIG_IPV6_ROUTER_PREF: rt6_probe is a nop). Beca=
use
>> of this, we have to create a neighbour entry on nexthop validation t=
o
>> track earlier validation errors. We recheck NUD state here to shortc=
urcuit
>> NUD_NOARP neighbours.
>>
>> This seems to be the least complex fix for stable and net. I'll intr=
oduce
>> a new route lookup flag 'idempotent' as soon as next opens to not le=
t
>> ip route get trigger active NUD validation if CONFIG_IPV6_ROUTER_PRE=
=46
>> is enabled. Currently we trigger active NUD validation if compiled w=
ith
>> CONFIG_IPV6_ROUTER_PREF.
>>
>> It also seems advantageous to make CONFIG_IPV6_ROUTER_PREF a runtime
>> switch and just select the default operation on compile-time.
>>
>> v2:
>> a) improved rt6_check_neigh logic and documented return values
>>
>> Reported-by: Pierre Emeriaud <petrus.lt@gmail.com>
>> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> ---
>>   net/ipv6/route.c | 62 +++++++++++++++++++++++++++++++++++---------=
------------
>>   1 file changed, 39 insertions(+), 23 deletions(-)
>>
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index bd5fd70..c5d9e68 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -531,28 +531,34 @@ static inline int rt6_check_dev(struct rt6_inf=
o *rt, int
>> oif)
>>       return 0;
>>   }
>>
>> -static inline bool rt6_check_neigh(struct rt6_info *rt)
>> +/* This function checks if a neighbour is reachable for routing
>> + * purposes. It returns -2 in case the neighbour should not get
>> + * selected as a viable router, -1 in case it should get selected w=
ith
>> + * lowest score and afterwards trying roundrobin. 1 indicates a
>> + * successfull verification.
>> + */
>> +static inline int rt6_check_neigh(struct rt6_info *rt)
>>   {
>>       struct neighbour *neigh;
>> -    bool ret =3D false;
>> +    int ret =3D -2;
>>
>>       if (rt->rt6i_flags & RTF_NONEXTHOP ||
>>           !(rt->rt6i_flags & RTF_GATEWAY))
>> -        return true;
>> +        return 1;
>>
>>       rcu_read_lock_bh();
>>       neigh =3D __ipv6_neigh_lookup_noref(rt->dst.dev, &rt->rt6i_gat=
eway);
>>       if (neigh) {
>>           read_lock(&neigh->lock);
>>           if (neigh->nud_state & NUD_VALID)
>> -            ret =3D true;
>> +            ret =3D 1;
>>   #ifdef CONFIG_IPV6_ROUTER_PREF
>>           else if (!(neigh->nud_state & NUD_FAILED))
>> -            ret =3D true;
>> +            ret =3D 1;
>>   #endif
>>           read_unlock(&neigh->lock);
>> -    } else if (IS_ENABLED(CONFIG_IPV6_ROUTER_PREF)) {
>> -        ret =3D true;
>> +    } else {
>> +        ret =3D IS_ENABLED(CONFIG_IPV6_ROUTER_PREF) ? 1 : -1;
>>       }
>>       rcu_read_unlock_bh();
>>
>> @@ -566,43 +572,52 @@ static int rt6_score_route(struct rt6_info *rt=
, int oif,
>>
>>       m =3D rt6_check_dev(rt, oif);
>>       if (!m && (strict & RT6_LOOKUP_F_IFACE))
>> -        return -1;
>> +        return -2;
>>   #ifdef CONFIG_IPV6_ROUTER_PREF
>>       m |=3D IPV6_DECODE_PREF(IPV6_EXTRACT_PREF(rt->rt6i_flags)) << =
2;
>>   #endif
>> -    if (!rt6_check_neigh(rt) && (strict & RT6_LOOKUP_F_REACHABLE))
>> -        return -1;
>> +    if (strict & RT6_LOOKUP_F_REACHABLE) {
>> +        int n =3D rt6_check_neigh(rt);
>> +        if (n < 0)
>> +            return n;
>> +    }
>>       return m;
>>   }
>>
>>   static struct rt6_info *find_match(struct rt6_info *rt, int oif, i=
nt strict,
>> -                   int *mpri, struct rt6_info *match)
>> +                   int *mpri, struct rt6_info *match,
>> +                   bool *do_rr)
>>   {
>>       int m;
>> +    bool match_do_rr =3D false;
>>
>>       if (rt6_check_expired(rt))
>>           goto out;
>>
>>       m =3D rt6_score_route(rt, oif, strict);
>> -    if (m < 0)
>> +    if (m =3D=3D -1 && !IS_ENABLED(CONFIG_IPV6_ROUTER_PREF)) {
>> +        match_do_rr =3D true;
>> +        m =3D 0; /* lowest valid score */
>> +    } else if (m < 0) {
>>           goto out;
>> +    }
>> +
>> +    if (strict & RT6_LOOKUP_F_REACHABLE)
>> +        rt6_probe(rt);
>>
>>       if (m > *mpri) {
>> -        if (strict & RT6_LOOKUP_F_REACHABLE)
>> -            rt6_probe(match);
>> +        *do_rr =3D match_do_rr;
>>           *mpri =3D m;
>>           match =3D rt;
>> -    } else if (strict & RT6_LOOKUP_F_REACHABLE) {
>> -        rt6_probe(rt);
>>       }
>> -
>>   out:
>>       return match;
>>   }
>>
>>   static struct rt6_info *find_rr_leaf(struct fib6_node *fn,
>>                        struct rt6_info *rr_head,
>> -                     u32 metric, int oif, int strict)
>> +                     u32 metric, int oif, int strict,
>> +                     bool *do_rr)
>>   {
>>       struct rt6_info *rt, *match;
>>       int mpri =3D -1;
>> @@ -610,10 +625,10 @@ static struct rt6_info *find_rr_leaf(struct fi=
b6_node *fn,
>>       match =3D NULL;
>>       for (rt =3D rr_head; rt && rt->rt6i_metric =3D=3D metric;
>>            rt =3D rt->dst.rt6_next)
>> -        match =3D find_match(rt, oif, strict, &mpri, match);
>> +        match =3D find_match(rt, oif, strict, &mpri, match, do_rr);
>>       for (rt =3D fn->leaf; rt && rt !=3D rr_head && rt->rt6i_metric=
 =3D=3D metric;
>>            rt =3D rt->dst.rt6_next)
>> -        match =3D find_match(rt, oif, strict, &mpri, match);
>> +        match =3D find_match(rt, oif, strict, &mpri, match, do_rr);
>>
>>       return match;
>>   }
>> @@ -622,15 +637,16 @@ static struct rt6_info *rt6_select(struct fib6=
_node *fn,
>> int oif, int strict)
>>   {
>>       struct rt6_info *match, *rt0;
>>       struct net *net;
>> +    bool do_rr =3D false;
>>
>>       rt0 =3D fn->rr_ptr;
>>       if (!rt0)
>>           fn->rr_ptr =3D rt0 =3D fn->leaf;
>>
>> -    match =3D find_rr_leaf(fn, rt0, rt0->rt6i_metric, oif, strict);
>> +    match =3D find_rr_leaf(fn, rt0, rt0->rt6i_metric, oif, strict,
>> +                 &do_rr);
>>
>> -    if (!match &&
>> -        (strict & RT6_LOOKUP_F_REACHABLE)) {
>> +    if (do_rr) {
>>           struct rt6_info *next =3D rt0->dst.rt6_next;
>>
>>           /* no entries matched; do round-robin */
>>
