From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net] ipv6: take rtnl_lock and mark mrt6 table as freed
 on namespace cleanup
Date: Tue, 23 Jul 2013 16:28:14 +0800
Message-ID: <51EE3E9E.9030406@windriver.com>
References: <20130722214553.GF6538@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <srivatsa.bhat@linux.vnet.ibm.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55930 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755951Ab3GWI1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 04:27:04 -0400
In-Reply-To: <20130722214553.GF6538@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hallo Hannes

On 2013=E5=B9=B407=E6=9C=8823=E6=97=A5 05:45, Hannes Frederic Sowa wrot=
e:
> Otherwise we end up dereferencing the already freed net->ipv6.mrt poi=
nter
> which leads to a panic (from Srivatsa S. Bhat):
>
> BUG: unable to handle kernel paging request at ffff882018552020
> IP: [<ffffffffa0366b02>] ip6mr_sk_done+0x32/0xb0 [ipv6]
> PGD 290a067 PUD 207ffe0067 PMD 207ff1d067 PTE 8000002018552060
> Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
> Modules linked in: ebtable_nat ebtables nfs fscache nf_conntrack_ipv4=
 nf_defrag_ipv4 ipt_REJECT xt_CHECKSUM iptable_mangle iptable_filter ip=
_tables nfsd lockd nfs_acl exportfs auth_rpcgss autofs4 sunrpc 8021q ga=
rp bridge stp llc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state=
 nf_conntrack ip6table_filter
> +ip6_tables ipv6 vfat fat vhost_net macvtap macvlan vhost tun kvm_int=
el kvm uinput iTCO_wdt iTCO_vendor_support cdc_ether usbnet mii microco=
de i2c_i801 i2c_core lpc_ich mfd_core shpchp ioatdma dca mlx4_core be2n=
et wmi acpi_cpufreq mperf ext4 jbd2 mbcache dm_mirror dm_region_hash dm=
_log dm_mod
> CPU: 0 PID: 7 Comm: kworker/u33:0 Not tainted 3.11.0-rc1-ea45e-a #4
> Hardware name: IBM  -[8737R2A]-/00Y2738, BIOS -[B2E120RUS-1.20]- 11/3=
0/2012
> Workqueue: netns cleanup_net
> task: ffff8810393641c0 ti: ffff881039366000 task.ti: ffff881039366000
> RIP: 0010:[<ffffffffa0366b02>]  [<ffffffffa0366b02>] ip6mr_sk_done+0x=
32/0xb0 [ipv6]
> RSP: 0018:ffff881039367bd8  EFLAGS: 00010286
> RAX: ffff881039367fd8 RBX: ffff882018552000 RCX: dead000000200200
> RDX: 0000000000000000 RSI: ffff881039367b68 RDI: ffff881039367b68
> RBP: ffff881039367bf8 R08: ffff881039367b68 R09: 2222222222222222
> R10: 2222222222222222 R11: 2222222222222222 R12: ffff882015a7a040
> R13: ffff882014eb89c0 R14: ffff8820289e2800 R15: 0000000000000000
> FS:  0000000000000000(0000) GS:ffff88103fc00000(0000) knlGS:000000000=
0000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: ffff882018552020 CR3: 0000000001c0b000 CR4: 00000000000407f0
> Stack:
>   ffff881039367c18 ffff882014eb89c0 ffff882015e28c00 0000000000000000
>   ffff881039367c18 ffffffffa034d9d1 ffff8820289e2800 ffff882014eb89c0
>   ffff881039367c58 ffffffff815bdecb ffffffff815bddf2 ffff882014eb89c0
> Call Trace:
>   [<ffffffffa034d9d1>] rawv6_close+0x21/0x40 [ipv6]
>   [<ffffffff815bdecb>] inet_release+0xfb/0x220
>   [<ffffffff815bddf2>] ? inet_release+0x22/0x220
>   [<ffffffffa032686f>] inet6_release+0x3f/0x50 [ipv6]
>   [<ffffffff8151c1d9>] sock_release+0x29/0xa0
>   [<ffffffff81525520>] sk_release_kernel+0x30/0x70
>   [<ffffffffa034f14b>] icmpv6_sk_exit+0x3b/0x80 [ipv6]
>   [<ffffffff8152fff9>] ops_exit_list+0x39/0x60
>   [<ffffffff815306fb>] cleanup_net+0xfb/0x1a0
>   [<ffffffff81075e3a>] process_one_work+0x1da/0x610
>   [<ffffffff81075dc9>] ? process_one_work+0x169/0x610
>   [<ffffffff81076390>] worker_thread+0x120/0x3a0
>   [<ffffffff81076270>] ? process_one_work+0x610/0x610
>   [<ffffffff8107da2e>] kthread+0xee/0x100
>   [<ffffffff8107d940>] ? __init_kthread_worker+0x70/0x70
>   [<ffffffff8162a99c>] ret_from_fork+0x7c/0xb0
>   [<ffffffff8107d940>] ? __init_kthread_worker+0x70/0x70

This call trace actually comes a long way down from put_net, indicating=
 net
reference count is ZERO, then clean all things up. Since Srivatsa didn'=
t
enable CONFIG_IPV6_MROUTE_MULTIPLE_TABLES, so mrt could only be net->ip=
v6.mrt6,
which is allocated in ip6mr_rules_init. The only place to free mrt6 is
ip6mr_rules_exit in this configuration.

Question is how could mrt6 be freed in ip6mr_rules_exit, and then put_n=
et has
decreased net->count to zero and then free all things up, all of this h=
appened
in boot up process? Even if mrt6 has been freed, subsequent access on t=
hat area
didn't necessarily cause page fault, PTE 8000002018552060 shows the map=
ping is
not present at all. I think SLAB did tired down page entry for kfreed a=
rea once
pte has been setup already.

The scenario is weird for me, or my ignorance reach a new limit :)


> Code: 20 48 89 5d e8 4c 89 65 f0 4c 89 6d f8 66 66 66 66 90 4c 8b 67 =
30 49 89 fd e8 db 3c 1e e1 49 8b 9c 24 90 08 00 00 48 85 db 74 06<4c>  =
39 6b 20 74 20 bb f3 ff ff ff e8 8e 3c 1e e1 89 d8 4c 8b 65
> RIP  [<ffffffffa0366b02>] ip6mr_sk_done+0x32/0xb0 [ipv6]
>   RSP<ffff881039367bd8>
> CR2: ffff882018552020
>
> Reported-by: Srivatsa S. Bhat<srivatsa.bhat@linux.vnet.ibm.com>
> Tested-by: Srivatsa S. Bhat<srivatsa.bhat@linux.vnet.ibm.com>
> Signed-off-by: Hannes Frederic Sowa<hannes@stressinduktion.org>
> ---
>   net/ipv6/ip6mr.c | 5 +++++
>   1 file changed, 5 insertions(+)
>
> diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
> index 583e8d4..03986d3 100644
> --- a/net/ipv6/ip6mr.c
> +++ b/net/ipv6/ip6mr.c
> @@ -259,10 +259,12 @@ static void __net_exit ip6mr_rules_exit(struct =
net *net)
>   {
>   	struct mr6_table *mrt, *next;
>
> +	rtnl_lock();
>   	list_for_each_entry_safe(mrt, next,&net->ipv6.mr6_tables, list) {
>   		list_del(&mrt->list);
>   		ip6mr_free_table(mrt);
>   	}
> +	rtnl_unlock();
>   	fib_rules_unregister(net->ipv6.mr6_rules_ops);
>   }
>   #else
> @@ -289,7 +291,10 @@ static int __net_init ip6mr_rules_init(struct ne=
t *net)
>
>   static void __net_exit ip6mr_rules_exit(struct net *net)
>   {
> +	rtnl_lock();
>   	ip6mr_free_table(net->ipv6.mrt6);
> +	net->ipv6.mrt6 =3D NULL;
> +	rtnl_unlock();
>   }
>   #endif
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
