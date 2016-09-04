From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next V5 4/4] net/sched: Introduce act_tunnel_key
Date: Sun, 4 Sep 2016 20:50:04 +0800
Message-ID: <201609042003.c5NeKTJO%fengguang.wu@intel.com>
References: <1472986555-14949-5-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, "David S. Miller" <davem@davemloft.net>,
        netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:65325 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751095AbcIDMun (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Sep 2016 08:50:43 -0400
Content-Disposition: inline
In-Reply-To: <1472986555-14949-5-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Amir,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Hadar-Hen-Zion/net-sched-ip-tunnel-metadata-set-release-classify-by-using-TC/20160904-185825
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/compiler.h:230:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> net/sched/act_tunnel_key.c:38:18: sparse: incompatible types in comparison expression (different address spaces)
   net/sched/act_tunnel_key.c:169:22: sparse: incompatible types in comparison expression (different address spaces)
   net/sched/act_tunnel_key.c:197:18: sparse: incompatible types in comparison expression (different address spaces)
   net/sched/act_tunnel_key.c:248:18: sparse: incompatible types in comparison expression (different address spaces)

vim +38 net/sched/act_tunnel_key.c

    22	#include <net/tc_act/tc_tunnel_key.h>
    23	
    24	#define TUNNEL_KEY_TAB_MASK     15
    25	
    26	static int tunnel_key_net_id;
    27	static struct tc_action_ops act_tunnel_key_ops;
    28	
    29	static int tunnel_key_act(struct sk_buff *skb, const struct tc_action *a,
    30				  struct tcf_result *res)
    31	{
    32		struct tcf_tunnel_key *t = to_tunnel_key(a);
    33		struct tcf_tunnel_key_params *params;
    34		int action;
    35	
    36		rcu_read_lock();
    37	
  > 38		params = rcu_dereference(t->params);
    39	
    40		tcf_lastuse_update(&t->tcf_tm);
    41		bstats_cpu_update(this_cpu_ptr(t->common.cpu_bstats), skb);
    42		action = params->action;
    43	
    44		switch (params->tcft_action) {
    45		case TCA_TUNNEL_KEY_ACT_RELEASE:
    46			skb_dst_drop(skb);

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
