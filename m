From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v4 net-next 1/1] net_sched: Introduce skbmod action
Date: Wed, 7 Sep 2016 11:29:55 +0800
Message-ID: <201609071117.pcOljRVB%fengguang.wu@intel.com>
References: <1473169060-29651-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org,
        daniel@iogearbox.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, alexei.starovoitov@gmail.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:61694 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755567AbcIGDbL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Sep 2016 23:31:11 -0400
Content-Disposition: inline
In-Reply-To: <1473169060-29651-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Jamal-Hadi-Salim/net_sched-Introduce-skbmod-action/20160907-095338
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/compiler.h:230:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> net/sched/act_skbmod.c:58:13: sparse: incompatible types in comparison expression (different address spaces)
   net/sched/act_skbmod.c:165:17: sparse: incompatible types in comparison expression (different address spaces)
   net/sched/act_skbmod.c:194:40: sparse: incompatible types in comparison expression (different address spaces)

vim +58 net/sched/act_skbmod.c

    42		 * then MAX_EDIT_LEN needs to change appropriately
    43		*/
    44		err = skb_ensure_writable(skb, ETH_HLEN);
    45		if (unlikely(err)) /* best policy is to drop on the floor */
    46			action = TC_ACT_SHOT;
    47	
    48		tcf_lastuse_update(&d->tcf_tm);
    49	
    50		rcu_read_lock();
    51		action = READ_ONCE(d->tcf_action);
    52		if (unlikely(action == TC_ACT_SHOT)) {
    53			d->tcf_qstats.drops++;
    54			rcu_read_unlock();
    55			return action;
    56		}
    57	
  > 58		p = rcu_dereference(d->skbmod_p);
    59		flags = p->flags;
    60		if (flags & SKBMOD_F_DMAC)
    61			ether_addr_copy(eth_hdr(skb)->h_dest, p->eth_dst);
    62		if (flags & SKBMOD_F_SMAC)
    63			ether_addr_copy(eth_hdr(skb)->h_source, p->eth_src);
    64		if (flags & SKBMOD_F_ETYPE)
    65			eth_hdr(skb)->h_proto = p->eth_type;
    66		rcu_read_unlock();

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
