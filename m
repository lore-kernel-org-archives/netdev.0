From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 136/385] net/sched/cls_route.c:565:22-26: ERROR: f
 is NULL but dereferenced.
Date: Sun, 18 Sep 2016 22:57:44 +0800
Message-ID: <201609182242.pYJ4QbRR%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: WANG Cong <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5983 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754634AbcIRO5w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Sep 2016 10:57:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   fd9527f404d51e50f40dac0d9a69f2eff3dac33e
commit: b9a24bb76bf611a5268ceffe04219e6ad264559b [136/385] net_sched: properly handle failure case of tcf_exts_init()


coccinelle warnings: (new ones prefixed by >>)

>> net/sched/cls_route.c:565:22-26: ERROR: f is NULL but dereferenced.

vim +565 net/sched/cls_route.c

   549						*fp = f->next;
   550						break;
   551					}
   552				}
   553			}
   554		}
   555	
   556		route4_reset_fastmap(head);
   557		*arg = (unsigned long)f;
   558		if (fold) {
   559			tcf_unbind_filter(tp, &fold->res);
   560			call_rcu(&fold->rcu, route4_delete_filter);
   561		}
   562		return 0;
   563	
   564	errout:
 > 565		tcf_exts_destroy(&f->exts);
   566		kfree(f);
   567		return err;
   568	}
   569	
   570	static void route4_walk(struct tcf_proto *tp, struct tcf_walker *arg)
   571	{
   572		struct route4_head *head = rtnl_dereference(tp->root);
   573		unsigned int h, h1;

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
