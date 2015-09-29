From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 6/6] ila: Add support for xfrm6_xlat_addr
Date: Wed, 30 Sep 2015 07:18:37 +0800
Message-ID: <201509300753.y5HAbZ1M%fengguang.wu@intel.com>
References: <1443565043-1287886-7-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org,
	kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30389 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750970AbbI2XTh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2015 19:19:37 -0400
Content-Disposition: inline
In-Reply-To: <1443565043-1287886-7-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

[auto build test results on next-20150929 -- if it's inappropriate base, please ignore]

reproduce:
  # apt-get install sparse
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> net/ipv6/ila/ila_xlat.c:218:24: sparse: incompatible types in comparison expression (different address spaces)
   net/ipv6/ila/ila_xlat.c:269:32: sparse: incompatible types in comparison expression (different address spaces)
   net/ipv6/ila/ila_xlat.c:275:25: sparse: incompatible types in comparison expression (different address spaces)
   net/ipv6/ila/ila_xlat.c:279:25: sparse: incompatible types in comparison expression (different address spaces)
   net/ipv6/ila/ila_xlat.c:315:31: sparse: incompatible types in comparison expression (different address spaces)
   net/ipv6/ila/ila_xlat.c:329:32: sparse: incompatible types in comparison expression (different address spaces)
   net/ipv6/ila/ila_xlat.c:201:23: sparse: incompatible types in comparison expression (different address spaces)
   net/ipv6/ila/ila_xlat.c:514:31: sparse: incompatible types in comparison expression (different address spaces)
   net/ipv6/ila/ila_xlat.c:184:23: sparse: incompatible types in comparison expression (different address spaces)
   net/ipv6/ila/ila_xlat.c: In function 'ila_xlat_fini':
   net/ipv6/ila/ila_xlat.c:636:6: warning: unused variable 'i' [-Wunused-variable]
     int i;
         ^

vim +218 net/ipv6/ila/ila_xlat.c

   202		}
   203	
   204		return NULL;
   205	}
   206	
   207	static inline void ila_release(struct ila_map *ila)
   208	{
   209		kfree_rcu(ila, rcu);
   210	}
   211	
   212	static void ila_free_cb(void *ptr, void *arg)
   213	{
   214		struct ila_map *ila = (struct ila_map *)ptr, *next;
   215	
   216		/* Assume rcu_readlock held */
   217		while (ila) {
 > 218			next = rcu_access_pointer(ila->next);
   219			ila_release(ila);
   220			ila = next;
   221		}
   222	}
   223	
   224	static int ila_add_mapping(struct net *net, struct ila_xlat_params *p)
   225	{
   226		struct ila_net *ilan = net_generic(net, ila_net_id);

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
