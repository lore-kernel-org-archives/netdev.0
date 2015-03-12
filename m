From: Madhu Challa <challa@noironetworks.com>
Subject: Re: [net-next PATCH] ipv4: FIB Local/MAIN table collapse
Date: Thu, 12 Mar 2015 12:20:15 -0700
Message-ID: <CAN_zqfNtYutMCuCuxTLy8bD8gUsPyLF4nb9_=TJx35JPcrs5Tg@mail.gmail.com>
References: <20150306213830.1139.16932.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	jiri@resnulli.us, sfeldma@gmail.com,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36296 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755014AbbCLTUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 15:20:16 -0400
Received: by padfa1 with SMTP id fa1so22912826pad.3
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 12:20:16 -0700 (PDT)
In-Reply-To: <20150306213830.1139.16932.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alex,

I see a null pointer deference in fib_trie_unmerge on boot with latest
net-next and thought it might be related. Pl let me know if you need
any additional info.

Thanks.

[  131.289254] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000030
[  131.298052] IP: [<ffffffff8171d75d>] fib_trie_unmerge+0x1d/0x2f0
[  131.304788] PGD 0
[  131.307045] Oops: 0000 [#1] SMP
[  131.310674] Modules linked in: iptable_mangle(+) xt_tcpudp
ip6table_filter ip6_tables ebtable_nat ebtables ipmi_devintf
xt_addrtype xt_conntrack ipt_MASQUERADE nf_nat_masquerade_ipv4
iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat
nf_conntrack bridge stp llc dm_thin_pool iptable_filter ip_tables
x_tables bnep rfcomm bluetooth x86_pkg_temp_thermal intel_powerclamp
coretemp kvm_intel kvm crc32_pclmul ghash_clmulni_intel aesni_intel
joydev aes_x86_64 lrw gf128mul glue_helper ablk_helper cryptd
microcode sb_edac edac_core ipmi_si lpc_ich ipmi_msghandler tpm_tis
wmi acpi_power_meter mac_hid parport_pc ppdev lp parport ixgbe
hid_generic igb vxlan ip6_udp_tunnel i2c_algo_bit udp_tunnel usbhid
dca hid ptp mdio pps_core
[  131.383538] CPU: 8 PID: 242 Comm: kworker/u48:1 Not tainted 4.0.0-rc3+ #2
[  131.391130] Hardware name: Cisco Systems Inc
UCSC-C220-M3S/UCSC-C220-M3S, BIOS C220M3.1.5.4f.0.111320130449
11/13/2013
[  131.403090] Workqueue: netns cleanup_net
[  131.407480] task: ffff88380213cb30 ti: ffff8838027e4000 task.ti:
ffff8838027e4000
[  131.415846] RIP: 0010:[<ffffffff8171d75d>]  [<ffffffff8171d75d>]
fib_trie_unmerge+0x1d/0x2f0
[  131.425297] RSP: 0018:ffff8838027e7c38  EFLAGS: 00010292
[  131.431233] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000038
[  131.439211] RDX: ffff88380cae8138 RSI: 00000000000000ff RDI: 0000000000000000
[  131.447191] RBP: ffff8838027e7c88 R08: ffff883810ca2f80 R09: 0000000180190008
[  131.455167] R10: ffffffff81682c43 R11: ffffea00e0432800 R12: ffff88380cae8000
[  131.463139] R13: ffff881fe27efa40 R14: ffff881fe27efac8 R15: ffff88380cae8008
[  131.471117] FS:  0000000000000000(0000) GS:ffff88387fc40000(0000)
knlGS:0000000000000000
[  131.480163] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  131.486583] CR2: 0000000000000030 CR3: 0000000001c0c000 CR4: 00000000001407e0
[  131.494562] Stack:
[  131.496839]  ffff8838027e7c68 ffffffff811c441a ffff883810ca3038
ffff883810ca2fb0
[  131.505278]  ffff883810ca3038 0000000000000000 ffff88380cae8000
ffff881fe27efa40
[  131.513714]  ffff881fe27efac8 ffff88380cae8008 ffff8838027e7ca8
ffffffff81717204
[  131.522147] Call Trace:
[  131.524911]  [<ffffffff811c441a>] ? kmem_cache_free+0xfa/0x160
[  131.531455]  [<ffffffff81717204>] fib_unmerge+0x24/0xd0
[  131.537324]  [<ffffffff8172282f>] fib4_rule_delete+0x1f/0x60
[  131.543674]  [<ffffffff816bb239>] fib_rules_unregister+0xb9/0xf0
[  131.550382]  [<ffffffff81722bb5>] fib4_rules_exit+0x15/0x20
[  131.556609]  [<ffffffff81716643>] ip_fib_net_exit+0x23/0x130
[  131.562933]  [<ffffffff81716785>] fib_net_exit+0x35/0x40
[  131.568871]  [<ffffffff8169409d>] ops_exit_list.isra.7+0x4d/0x70
[  131.575589]  [<ffffffff81694e00>] cleanup_net+0x1b0/0x250
[  131.581628]  [<ffffffff81087a4d>] process_one_work+0x22d/0x400
[  131.588145]  [<ffffffff810882ed>] worker_thread+0x2fd/0x550
[  131.594375]  [<ffffffff81087ff0>] ? rescuer_thread+0x3d0/0x3d0
[  131.600904]  [<ffffffff8108d603>] kthread+0xe3/0xf0
[  131.606355]  [<ffffffff8108d520>] ? kthread_stop+0xf0/0xf0
[  131.612500]  [<ffffffff817a4f58>] ret_from_fork+0x58/0x90
[  131.618538]  [<ffffffff8108d520>] ? kthread_stop+0xf0/0xf0
[  131.624675] Code: c3 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f
44 00 00 55 48 8d 4f 38 48 89 f8 48 89 e5 41 57 41 56 41 55 41 54 53
48 83 ec 28 <48> 8b 57 30 48 39 ca 48 89 55 c8 0f 84 aa 02 00 00 31 f6
bf ff
[  131.647012] RIP  [<ffffffff8171d75d>] fib_trie_unmerge+0x1d/0x2f0
[  131.653850]  RSP <ffff8838027e7c38>
[  131.657755] CR2: 0000000000000030
[  131.661468] ---[ end trace 8db31cc50a0eb505 ]---
[  131.748516] BUG: unable to handle kernel paging request at ffffffffffffffd8
[  131.756344] IP: [<ffffffff8108daa0>] kthread_data+0x10/0x20
[  131.762599] PGD 1c0f067 PUD 1c11067 PMD 0
[  131.767240] Oops: 0000 [#2] SMP

On Fri, Mar 6, 2015 at 1:47 PM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
> This patch is meant to collapse local and main into one by converting
> tb_data from an array to a pointer.  Doing this allows us to point the
> local table into the main while maintaining the same variables in the
> table.
>
> As such the tb_data was converted from an array to a pointer, and a new
> array called data is added in order to still provide an object for tb_data
> to point to.
>
> In order to track the origin of the fib aliases a tb_id value was added in
> a hole that existed on 64b systems.  Using this we can also reverse the
> merge in the event that custom FIB rules are enabled.
>
> With this patch I am seeing an improvement of 20ns to 30ns for routing
> lookups as long as custom rules are not enabled, with custom rules enabled
> we fall back to split tables and the original behavior.
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>
> Changes since the RFC:
>   Added tb_id value so I could split main and local for custom rules
>   Added functionality to split tables if custom rules were enabled
>   Added table replacement and unmerge functions
>
> I have done some testing on this to verify performance gains and that I can
> split the tables correctly when I enable custom rules, but this patch is
> what I would consider to be high risk since I am certain there are things I
> have not considered.
>
> If this gets pulled into someone's switchdev tree instead of into net-next I
> would be perfectly fine with that as I am sure this can use some additional
> testing.
>
>  include/net/fib_rules.h |    2 -
>  include/net/ip_fib.h    |   26 ++-----
>  net/core/fib_rules.c    |    8 ++
>  net/ipv4/fib_frontend.c |   59 ++++++++++++++--
>  net/ipv4/fib_lookup.h   |    1
>  net/ipv4/fib_rules.c    |   20 ++++-
>  net/ipv4/fib_trie.c     |  172 +++++++++++++++++++++++++++++++++++++++++++++--
>  7 files changed, 250 insertions(+), 38 deletions(-)
>
> diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
> index e584de1..88d2ae5 100644
> --- a/include/net/fib_rules.h
> +++ b/include/net/fib_rules.h
> @@ -58,7 +58,7 @@ struct fib_rules_ops {
>                                              struct sk_buff *,
>                                              struct fib_rule_hdr *,
>                                              struct nlattr **);
> -       void                    (*delete)(struct fib_rule *);
> +       int                     (*delete)(struct fib_rule *);
>         int                     (*compare)(struct fib_rule *,
>                                            struct fib_rule_hdr *,
>                                            struct nlattr **);
> diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> index 1657604..54271ed 100644
> --- a/include/net/ip_fib.h
> +++ b/include/net/ip_fib.h
> @@ -186,7 +186,8 @@ struct fib_table {
>         int                     tb_default;
>         int                     tb_num_default;
>         struct rcu_head         rcu;
> -       unsigned long           tb_data[0];
> +       unsigned long           *tb_data;
> +       unsigned long           __data[0];
>  };
>
>  int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
> @@ -196,11 +197,10 @@ int fib_table_delete(struct fib_table *, struct fib_config *);
>  int fib_table_dump(struct fib_table *table, struct sk_buff *skb,
>                    struct netlink_callback *cb);
>  int fib_table_flush(struct fib_table *table);
> +struct fib_table *fib_trie_unmerge(struct fib_table *main_tb);
>  void fib_table_flush_external(struct fib_table *table);
>  void fib_free_table(struct fib_table *tb);
>
> -
> -
>  #ifndef CONFIG_IP_MULTIPLE_TABLES
>
>  #define TABLE_LOCAL_INDEX      (RT_TABLE_LOCAL & (FIB_TABLE_HASHSZ - 1))
> @@ -229,18 +229,13 @@ static inline int fib_lookup(struct net *net, const struct flowi4 *flp,
>                              struct fib_result *res)
>  {
>         struct fib_table *tb;
> -       int err;
> +       int err = -ENETUNREACH;
>
>         rcu_read_lock();
>
> -       for (err = 0; !err; err = -ENETUNREACH) {
> -               tb = fib_get_table(net, RT_TABLE_LOCAL);
> -               if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
> -                       break;
> -               tb = fib_get_table(net, RT_TABLE_MAIN);
> -               if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
> -                       break;
> -       }
> +       tb = fib_get_table(net, RT_TABLE_MAIN);
> +       if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
> +               err = 0;
>
>         rcu_read_unlock();
>
> @@ -270,10 +265,6 @@ static inline int fib_lookup(struct net *net, struct flowi4 *flp,
>         res->tclassid = 0;
>
>         for (err = 0; !err; err = -ENETUNREACH) {
> -               tb = rcu_dereference_rtnl(net->ipv4.fib_local);
> -               if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
> -                       break;
> -
>                 tb = rcu_dereference_rtnl(net->ipv4.fib_main);
>                 if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
>                         break;
> @@ -309,6 +300,7 @@ static inline int fib_num_tclassid_users(struct net *net)
>         return 0;
>  }
>  #endif
> +int fib_unmerge(struct net *net);
>  void fib_flush_external(struct net *net);
>
>  /* Exported by fib_semantics.c */
> @@ -320,7 +312,7 @@ void fib_select_multipath(struct fib_result *res);
>
>  /* Exported by fib_trie.c */
>  void fib_trie_init(void);
> -struct fib_table *fib_trie_table(u32 id);
> +struct fib_table *fib_trie_table(u32 id, struct fib_table *alias);
>
>  static inline void fib_combine_itag(u32 *itag, const struct fib_result *res)
>  {
> diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
> index 44706e8..b55677f 100644
> --- a/net/core/fib_rules.c
> +++ b/net/core/fib_rules.c
> @@ -492,6 +492,12 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh)
>                         goto errout;
>                 }
>
> +               if (ops->delete) {
> +                       err = ops->delete(rule);
> +                       if (err)
> +                               goto errout;
> +               }
> +
>                 list_del_rcu(&rule->list);
>
>                 if (rule->action == FR_ACT_GOTO) {
> @@ -517,8 +523,6 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh)
>
>                 notify_rule_change(RTM_DELRULE, rule, ops, nlh,
>                                    NETLINK_CB(skb).portid);
> -               if (ops->delete)
> -                       ops->delete(rule);
>                 fib_rule_put(rule);
>                 flush_route_cache(ops);
>                 rules_ops_put(ops);
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index e067770..7cda3b0 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -52,14 +52,14 @@ static int __net_init fib4_rules_init(struct net *net)
>  {
>         struct fib_table *local_table, *main_table;
>
> -       local_table = fib_trie_table(RT_TABLE_LOCAL);
> -       if (local_table == NULL)
> -               return -ENOMEM;
> -
> -       main_table  = fib_trie_table(RT_TABLE_MAIN);
> +       main_table  = fib_trie_table(RT_TABLE_MAIN, NULL);
>         if (main_table == NULL)
>                 goto fail;
>
> +       local_table = fib_trie_table(RT_TABLE_LOCAL, main_table);
> +       if (local_table == NULL)
> +               return -ENOMEM;
> +
>         hlist_add_head_rcu(&local_table->tb_hlist,
>                                 &net->ipv4.fib_table_hash[TABLE_LOCAL_INDEX]);
>         hlist_add_head_rcu(&main_table->tb_hlist,
> @@ -74,7 +74,7 @@ fail:
>
>  struct fib_table *fib_new_table(struct net *net, u32 id)
>  {
> -       struct fib_table *tb;
> +       struct fib_table *tb, *alias = NULL;
>         unsigned int h;
>
>         if (id == 0)
> @@ -83,7 +83,10 @@ struct fib_table *fib_new_table(struct net *net, u32 id)
>         if (tb)
>                 return tb;
>
> -       tb = fib_trie_table(id);
> +       if (id == RT_TABLE_LOCAL)
> +               alias = fib_new_table(net, RT_TABLE_MAIN);
> +
> +       tb = fib_trie_table(id, alias);
>         if (!tb)
>                 return NULL;
>
> @@ -126,6 +129,48 @@ struct fib_table *fib_get_table(struct net *net, u32 id)
>  }
>  #endif /* CONFIG_IP_MULTIPLE_TABLES */
>
> +static void fib_replace_table(struct net *net, struct fib_table *old,
> +                             struct fib_table *new)
> +{
> +#ifdef CONFIG_IP_MULTIPLE_TABLES
> +       switch (new->tb_id) {
> +       case RT_TABLE_LOCAL:
> +               rcu_assign_pointer(net->ipv4.fib_local, new);
> +               break;
> +       case RT_TABLE_MAIN:
> +               rcu_assign_pointer(net->ipv4.fib_main, new);
> +               break;
> +       case RT_TABLE_DEFAULT:
> +               rcu_assign_pointer(net->ipv4.fib_default, new);
> +               break;
> +       default:
> +               break;
> +       }
> +
> +#endif
> +       /* replace the old table in the hlist */
> +       hlist_replace_rcu(&old->tb_hlist, &new->tb_hlist);
> +}
> +
> +int fib_unmerge(struct net *net)
> +{
> +       struct fib_table *old, *new;
> +
> +       old = fib_get_table(net, RT_TABLE_LOCAL);
> +       new = fib_trie_unmerge(old);
> +
> +       if (!new)
> +               return -ENOMEM;
> +
> +       /* replace merged table with clean table */
> +       if (new != old) {
> +               fib_replace_table(net, old, new);
> +               fib_free_table(old);
> +       }
> +
> +       return 0;
> +}
> +
>  static void fib_flush(struct net *net)
>  {
>         int flushed = 0;
> diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
> index ae2e6ee..c6211ed 100644
> --- a/net/ipv4/fib_lookup.h
> +++ b/net/ipv4/fib_lookup.h
> @@ -12,6 +12,7 @@ struct fib_alias {
>         u8                      fa_type;
>         u8                      fa_state;
>         u8                      fa_slen;
> +       u32                     tb_id;
>         struct rcu_head         rcu;
>  };
>
> diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
> index 190d0d0..e9bc5e4 100644
> --- a/net/ipv4/fib_rules.c
> +++ b/net/ipv4/fib_rules.c
> @@ -174,6 +174,11 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
>         if (frh->tos & ~IPTOS_TOS_MASK)
>                 goto errout;
>
> +       /* split local/main if they are not already split */
> +       err = fib_unmerge(net);
> +       if (err)
> +               goto errout;
> +
>         if (rule->table == RT_TABLE_UNSPEC) {
>                 if (rule->action == FR_ACT_TO_TBL) {
>                         struct fib_table *table;
> @@ -216,17 +221,24 @@ errout:
>         return err;
>  }
>
> -static void fib4_rule_delete(struct fib_rule *rule)
> +static int fib4_rule_delete(struct fib_rule *rule)
>  {
>         struct net *net = rule->fr_net;
> -#ifdef CONFIG_IP_ROUTE_CLASSID
> -       struct fib4_rule *rule4 = (struct fib4_rule *) rule;
> +       int err;
>
> -       if (rule4->tclassid)
> +       /* split local/main if they are not already split */
> +       err = fib_unmerge(net);
> +       if (err)
> +               goto errout;
> +
> +#ifdef CONFIG_IP_ROUTE_CLASSID
> +       if (((struct fib4_rule *)rule)->tclassid)
>                 net->ipv4.fib_num_tclassid_users--;
>  #endif
>         net->ipv4.fib_has_custom_rules = true;
>         fib_flush_external(rule->fr_net);
> +errout:
> +       return err;
>  }
>
>  static int fib4_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index 9095545..1fa862b 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -1122,6 +1122,9 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>                                 break;
>                         if (fa->fa_info->fib_priority != fi->fib_priority)
>                                 break;
> +                       /* duplicate entry from another table */
> +                       if (WARN_ON(fa->tb_id != tb->tb_id))
> +                               continue;
>                         if (fa->fa_type == cfg->fc_type &&
>                             fa->fa_info == fi) {
>                                 fa_match = fa;
> @@ -1198,6 +1201,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>         new_fa->fa_type = cfg->fc_type;
>         new_fa->fa_state = 0;
>         new_fa->fa_slen = slen;
> +       new_fa->tb_id = tb->tb_id;
>
>         /* (Optionally) offload fib entry to switch hardware. */
>         err = netdev_switch_fib_ipv4_add(key, plen, fi, tos,
> @@ -1216,7 +1220,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>                 tb->tb_num_default++;
>
>         rt_cache_flush(cfg->fc_nlinfo.nl_net);
> -       rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id,
> +       rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, new_fa->tb_id,
>                   &cfg->fc_nlinfo, 0);
>  succeeded:
>         return 0;
> @@ -1242,7 +1246,7 @@ static inline t_key prefix_mismatch(t_key key, struct key_vector *n)
>  int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
>                      struct fib_result *res, int fib_flags)
>  {
> -       struct trie *t = (struct trie *)tb->tb_data;
> +       struct trie *t = (struct trie *) tb->tb_data;
>  #ifdef CONFIG_IP_FIB_TRIE_STATS
>         struct trie_use_stats __percpu *stats = t->stats;
>  #endif
> @@ -1482,6 +1486,9 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
>                 if ((fa->fa_slen != slen) || (fa->fa_tos != tos))
>                         break;
>
> +               if (fa->tb_id != tb->tb_id)
> +                       continue;
> +
>                 if ((!cfg->fc_type || fa->fa_type == cfg->fc_type) &&
>                     (cfg->fc_scope == RT_SCOPE_NOWHERE ||
>                      fa->fa_info->fib_scope == cfg->fc_scope) &&
> @@ -1575,6 +1582,120 @@ found:
>         return n;
>  }
>
> +static void fib_trie_free(struct fib_table *tb)
> +{
> +       struct trie *t = (struct trie *)tb->tb_data;
> +       struct key_vector *pn = t->kv;
> +       unsigned long cindex = 1;
> +       struct hlist_node *tmp;
> +       struct fib_alias *fa;
> +
> +       /* walk trie in reverse order and free everything */
> +       for (;;) {
> +               struct key_vector *n;
> +
> +               if (!(cindex--)) {
> +                       t_key pkey = pn->key;
> +
> +                       if (IS_TRIE(pn))
> +                               break;
> +
> +                       n = pn;
> +                       pn = node_parent(pn);
> +
> +                       /* drop emptied tnode */
> +                       put_child_root(pn, n->key, NULL);
> +                       node_free(n);
> +
> +                       cindex = get_index(pkey, pn);
> +
> +                       continue;
> +               }
> +
> +               /* grab the next available node */
> +               n = get_child(pn, cindex);
> +               if (!n)
> +                       continue;
> +
> +               if (IS_TNODE(n)) {
> +                       /* record pn and cindex for leaf walking */
> +                       pn = n;
> +                       cindex = 1ul << n->bits;
> +
> +                       continue;
> +               }
> +
> +               hlist_for_each_entry_safe(fa, tmp, &n->leaf, fa_list) {
> +                       hlist_del_rcu(&fa->fa_list);
> +                       alias_free_mem_rcu(fa);
> +               }
> +
> +               put_child_root(pn, n->key, NULL);
> +               node_free(n);
> +       }
> +
> +#ifdef CONFIG_IP_FIB_TRIE_STATS
> +       free_percpu(t->stats);
> +#endif
> +       kfree(tb);
> +}
> +
> +struct fib_table *fib_trie_unmerge(struct fib_table *oldtb)
> +{
> +       struct trie *ot = (struct trie *)oldtb->tb_data;
> +       struct key_vector *l, *tp = ot->kv;
> +       struct fib_table *local_tb;
> +       struct fib_alias *fa;
> +       struct trie *lt;
> +       t_key key = 0;
> +
> +       if (oldtb->tb_data == oldtb->__data)
> +               return oldtb;
> +
> +       local_tb = fib_trie_table(RT_TABLE_LOCAL, NULL);
> +       if (!local_tb)
> +               return NULL;
> +
> +       lt = (struct trie *)local_tb->tb_data;
> +
> +       while ((l = leaf_walk_rcu(&tp, key)) != NULL) {
> +               struct key_vector *local_l = NULL, *local_tp;
> +
> +               hlist_for_each_entry_rcu(fa, &l->leaf, fa_list) {
> +                       struct fib_alias *new_fa;
> +
> +                       if (local_tb->tb_id != fa->tb_id)
> +                               continue;
> +
> +                       /* clone fa for new local table */
> +                       new_fa = kmem_cache_alloc(fn_alias_kmem, GFP_KERNEL);
> +                       if (!new_fa)
> +                               goto out;
> +
> +                       memcpy(new_fa, fa, sizeof(*fa));
> +
> +                       /* insert clone into table */
> +                       if (!local_l)
> +                               local_l = fib_find_node(lt, &local_tp, l->key);
> +
> +                       if (fib_insert_alias(lt, local_tp, local_l, new_fa,
> +                                            NULL, l->key))
> +                               goto out;
> +               }
> +
> +               /* stop loop if key wrapped back to 0 */
> +               key = l->key + 1;
> +               if (key < l->key)
> +                       break;
> +       }
> +
> +       return local_tb;
> +out:
> +       fib_trie_free(local_tb);
> +
> +       return NULL;
> +}
> +
>  /* Caller must hold RTNL */
>  void fib_table_flush_external(struct fib_table *tb)
>  {
> @@ -1586,6 +1707,7 @@ void fib_table_flush_external(struct fib_table *tb)
>
>         /* walk trie in reverse order */
>         for (;;) {
> +               unsigned char slen = 0;
>                 struct key_vector *n;
>
>                 if (!(cindex--)) {
> @@ -1595,8 +1717,8 @@ void fib_table_flush_external(struct fib_table *tb)
>                         if (IS_TRIE(pn))
>                                 break;
>
> -                       /* no need to resize like in flush below */
> -                       pn = node_parent(pn);
> +                       /* resize completed node */
> +                       pn = resize(t, pn);
>                         cindex = get_index(pkey, pn);
>
>                         continue;
> @@ -1618,6 +1740,18 @@ void fib_table_flush_external(struct fib_table *tb)
>                 hlist_for_each_entry_safe(fa, tmp, &n->leaf, fa_list) {
>                         struct fib_info *fi = fa->fa_info;
>
> +                       /* if alias was cloned to local then we just
> +                        * need to remove the local copy from main
> +                        */
> +                       if (tb->tb_id != fa->tb_id) {
> +                               hlist_del_rcu(&fa->fa_list);
> +                               alias_free_mem_rcu(fa);
> +                               continue;
> +                       }
> +
> +                       /* record local slen */
> +                       slen = fa->fa_slen;
> +
>                         if (!fi || !(fi->fib_flags & RTNH_F_EXTERNAL))
>                                 continue;
>
> @@ -1626,6 +1760,16 @@ void fib_table_flush_external(struct fib_table *tb)
>                                                    fi, fa->fa_tos,
>                                                    fa->fa_type, tb->tb_id);
>                 }
> +
> +               /* update leaf slen */
> +               n->slen = slen;
> +
> +               if (hlist_empty(&n->leaf)) {
> +                       put_child_root(pn, n->key, NULL);
> +                       node_free(n);
> +               } else {
> +                       leaf_pull_suffix(pn, n);
> +               }
>         }
>  }
>
> @@ -1710,7 +1854,8 @@ static void __trie_free_rcu(struct rcu_head *head)
>  #ifdef CONFIG_IP_FIB_TRIE_STATS
>         struct trie *t = (struct trie *)tb->tb_data;
>
> -       free_percpu(t->stats);
> +       if (tb->tb_data == tb->__data)
> +               free_percpu(t->stats);
>  #endif /* CONFIG_IP_FIB_TRIE_STATS */
>         kfree(tb);
>  }
> @@ -1737,6 +1882,11 @@ static int fn_trie_dump_leaf(struct key_vector *l, struct fib_table *tb,
>                         continue;
>                 }
>
> +               if (tb->tb_id != fa->tb_id) {
> +                       i++;
> +                       continue;
> +               }
> +
>                 if (fib_dump_info(skb, NETLINK_CB(cb->skb).portid,
>                                   cb->nlh->nlmsg_seq,
>                                   RTM_NEWROUTE,
> @@ -1803,18 +1953,26 @@ void __init fib_trie_init(void)
>                                            0, SLAB_PANIC, NULL);
>  }
>
> -struct fib_table *fib_trie_table(u32 id)
> +struct fib_table *fib_trie_table(u32 id, struct fib_table *alias)
>  {
>         struct fib_table *tb;
>         struct trie *t;
> +       size_t sz = sizeof(*tb);
> +
> +       if (!alias)
> +               sz += sizeof(struct trie);
>
> -       tb = kzalloc(sizeof(*tb) + sizeof(struct trie), GFP_KERNEL);
> +       tb = kzalloc(sz, GFP_KERNEL);
>         if (tb == NULL)
>                 return NULL;
>
>         tb->tb_id = id;
>         tb->tb_default = -1;
>         tb->tb_num_default = 0;
> +       tb->tb_data = (alias ? alias->__data : tb->__data);
> +
> +       if (alias)
> +               return tb;
>
>         t = (struct trie *) tb->tb_data;
>         t->kv[0].pos = KEYLENGTH;
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
