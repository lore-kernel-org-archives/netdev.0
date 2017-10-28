From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 2/2] net sched act_vlan: VLAN action rewrite to
 use RCU lock/unlock and update
Date: Sun, 29 Oct 2017 07:22:48 +0800
Message-ID: <201710290752.G27Wb3AP%fengguang.wu@intel.com>
References: <1509116964-8234-1-git-send-email-manish.kurup@verizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, davem@davemloft.net, netdev@vger.kernel.org,
        aring@mojatatu.com, mrv@mojatatu.com, kurup.manish@gmail.com,
        Manish Kurup <manish.kurup@verizon.com>
To: Manish Kurup <kurup.manish@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:1747 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751446AbdJ1XXt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 28 Oct 2017 19:23:49 -0400
Content-Disposition: inline
In-Reply-To: <1509116964-8234-1-git-send-email-manish.kurup@verizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Manish,

Thank you for the patch! Yet we hit a small issue.
[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Manish-Kurup/net-sched-act_vlan-Change-stats-update-to-use-per-core-stats/20171029-053449
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)


vim +70 drivers/net/ethernet/netronome/nfp/flower/action.c

1a1e586f Pieter Jansen van Vuuren 2017-06-29  55  
1a1e586f Pieter Jansen van Vuuren 2017-06-29  56  static void
1a1e586f Pieter Jansen van Vuuren 2017-06-29  57  nfp_fl_push_vlan(struct nfp_fl_push_vlan *push_vlan,
1a1e586f Pieter Jansen van Vuuren 2017-06-29  58  		 const struct tc_action *action)
1a1e586f Pieter Jansen van Vuuren 2017-06-29  59  {
1a1e586f Pieter Jansen van Vuuren 2017-06-29  60  	size_t act_size = sizeof(struct nfp_fl_push_vlan);
1a1e586f Pieter Jansen van Vuuren 2017-06-29  61  	struct tcf_vlan *vlan = to_vlan(action);
1a1e586f Pieter Jansen van Vuuren 2017-06-29  62  	u16 tmp_push_vlan_tci;
1a1e586f Pieter Jansen van Vuuren 2017-06-29  63  
62d3f60b Pieter Jansen van Vuuren 2017-10-20  64  	push_vlan->head.jump_id = NFP_FL_ACTION_OPCODE_PUSH_VLAN;
62d3f60b Pieter Jansen van Vuuren 2017-10-20  65  	push_vlan->head.len_lw = act_size >> NFP_FL_LW_SIZ;
1a1e586f Pieter Jansen van Vuuren 2017-06-29  66  	push_vlan->reserved = 0;
1a1e586f Pieter Jansen van Vuuren 2017-06-29  67  	push_vlan->vlan_tpid = tcf_vlan_push_proto(action);
1a1e586f Pieter Jansen van Vuuren 2017-06-29  68  
1a1e586f Pieter Jansen van Vuuren 2017-06-29  69  	tmp_push_vlan_tci =
1a1e586f Pieter Jansen van Vuuren 2017-06-29 @70  		FIELD_PREP(NFP_FL_PUSH_VLAN_PRIO, vlan->tcfv_push_prio) |
1a1e586f Pieter Jansen van Vuuren 2017-06-29  71  		FIELD_PREP(NFP_FL_PUSH_VLAN_VID, vlan->tcfv_push_vid) |
1a1e586f Pieter Jansen van Vuuren 2017-06-29  72  		NFP_FL_PUSH_VLAN_CFI;
1a1e586f Pieter Jansen van Vuuren 2017-06-29  73  	push_vlan->vlan_tci = cpu_to_be16(tmp_push_vlan_tci);
1a1e586f Pieter Jansen van Vuuren 2017-06-29  74  }
1a1e586f Pieter Jansen van Vuuren 2017-06-29  75  

:::::: The code at line 70 was first introduced by commit
:::::: 1a1e586f54bfe54a0ba7ea0ac9b8c7b1d3e655f6 nfp: add basic action capabilities to flower offloads

:::::: TO: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
:::::: CC: David S. Miller <davem@davemloft.net>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
