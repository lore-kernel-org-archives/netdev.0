From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 2/4] flow_dissector: Get vlan priority in
 addition to vlan id
Date: Thu, 11 Aug 2016 05:58:07 +0800
Message-ID: <201608110519.ecG3SB3c%fengguang.wu@intel.com>
References: <1470835943-9042-3-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="PEIAKu/WMn1b1Hv9"
Cc: kbuild-all@01.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:61216 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752320AbcHJV7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2016 17:59:20 -0400
Content-Disposition: inline
In-Reply-To: <1470835943-9042-3-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Hadar,

[auto build test ERROR on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Hadar-Hen-Zion/flow_dissector-Get-vlan-info-from-skb-vlan_tci-instead-of-skb-data/20160811-042500
config: cris-etrax-100lx_v2_defconfig (attached as .config)
compiler: cris-linux-gcc (GCC) 4.6.3
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=cris 

All errors (new ones prefixed by >>):

   In function 'flow_keys_hash_length.isra.6',
       inlined from '__flow_hash_from_keys' at net/core/flow_dissector.c:599:26,
       inlined from 'flow_hash_from_keys' at net/core/flow_dissector.c:610:2:
>> net/core/flow_dissector.c:512:2: error: call to '__compiletime_assert_512' declared with attribute error: BUILD_BUG_ON failed: (sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32)
   In function 'flow_keys_hash_length.isra.6',
       inlined from '__flow_hash_from_keys' at net/core/flow_dissector.c:599:26,
       inlined from '__skb_get_hash_symmetric' at net/core/flow_dissector.c:663:2:
>> net/core/flow_dissector.c:512:2: error: call to '__compiletime_assert_512' declared with attribute error: BUILD_BUG_ON failed: (sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32)
   In function 'flow_keys_hash_length.isra.6',
       inlined from '__flow_hash_from_keys' at net/core/flow_dissector.c:599:26,
       inlined from '__skb_get_hash' at net/core/flow_dissector.c:620:2:
>> net/core/flow_dissector.c:512:2: error: call to '__compiletime_assert_512' declared with attribute error: BUILD_BUG_ON failed: (sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32)
   In function 'flow_keys_hash_length.isra.6',
       inlined from '__flow_hash_from_keys' at net/core/flow_dissector.c:599:26,
       inlined from 'skb_get_hash_perturb' at net/core/flow_dissector.c:620:2:
>> net/core/flow_dissector.c:512:2: error: call to '__compiletime_assert_512' declared with attribute error: BUILD_BUG_ON failed: (sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32)

vim +/__compiletime_assert_512 +512 net/core/flow_dissector.c

20a17bf6 David S. Miller      2015-09-01  506  	return (const u32 *)(p + FLOW_KEYS_HASH_OFFSET);
42aecaa9 Tom Herbert          2015-06-04  507  }
42aecaa9 Tom Herbert          2015-06-04  508  
20a17bf6 David S. Miller      2015-09-01  509  static inline size_t flow_keys_hash_length(const struct flow_keys *flow)
42aecaa9 Tom Herbert          2015-06-04  510  {
c3f83241 Tom Herbert          2015-06-04  511  	size_t diff = FLOW_KEYS_HASH_OFFSET + sizeof(flow->addrs);
42aecaa9 Tom Herbert          2015-06-04 @512  	BUILD_BUG_ON((sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32));
c3f83241 Tom Herbert          2015-06-04  513  	BUILD_BUG_ON(offsetof(typeof(*flow), addrs) !=
c3f83241 Tom Herbert          2015-06-04  514  		     sizeof(*flow) - sizeof(flow->addrs));
c3f83241 Tom Herbert          2015-06-04  515  
c3f83241 Tom Herbert          2015-06-04  516  	switch (flow->control.addr_type) {
c3f83241 Tom Herbert          2015-06-04  517  	case FLOW_DISSECTOR_KEY_IPV4_ADDRS:
c3f83241 Tom Herbert          2015-06-04  518  		diff -= sizeof(flow->addrs.v4addrs);
c3f83241 Tom Herbert          2015-06-04  519  		break;
c3f83241 Tom Herbert          2015-06-04  520  	case FLOW_DISSECTOR_KEY_IPV6_ADDRS:
c3f83241 Tom Herbert          2015-06-04  521  		diff -= sizeof(flow->addrs.v6addrs);
c3f83241 Tom Herbert          2015-06-04  522  		break;
9f249089 Tom Herbert          2015-06-04  523  	case FLOW_DISSECTOR_KEY_TIPC_ADDRS:
9f249089 Tom Herbert          2015-06-04  524  		diff -= sizeof(flow->addrs.tipcaddrs);
9f249089 Tom Herbert          2015-06-04  525  		break;
c3f83241 Tom Herbert          2015-06-04  526  	}
c3f83241 Tom Herbert          2015-06-04  527  	return (sizeof(*flow) - diff) / sizeof(u32);
66415cf8 Hannes Frederic Sowa 2013-10-23  528  }
66415cf8 Hannes Frederic Sowa 2013-10-23  529  
c3f83241 Tom Herbert          2015-06-04  530  __be32 flow_get_u32_src(const struct flow_keys *flow)
5ed20a68 Tom Herbert          2014-07-01  531  {
c3f83241 Tom Herbert          2015-06-04  532  	switch (flow->control.addr_type) {
c3f83241 Tom Herbert          2015-06-04  533  	case FLOW_DISSECTOR_KEY_IPV4_ADDRS:
c3f83241 Tom Herbert          2015-06-04  534  		return flow->addrs.v4addrs.src;
c3f83241 Tom Herbert          2015-06-04  535  	case FLOW_DISSECTOR_KEY_IPV6_ADDRS:
c3f83241 Tom Herbert          2015-06-04  536  		return (__force __be32)ipv6_addr_hash(
c3f83241 Tom Herbert          2015-06-04  537  			&flow->addrs.v6addrs.src);
9f249089 Tom Herbert          2015-06-04  538  	case FLOW_DISSECTOR_KEY_TIPC_ADDRS:
9f249089 Tom Herbert          2015-06-04  539  		return flow->addrs.tipcaddrs.srcnode;
c3f83241 Tom Herbert          2015-06-04  540  	default:
c3f83241 Tom Herbert          2015-06-04  541  		return 0;
c3f83241 Tom Herbert          2015-06-04  542  	}
c3f83241 Tom Herbert          2015-06-04  543  }
c3f83241 Tom Herbert          2015-06-04  544  EXPORT_SYMBOL(flow_get_u32_src);
c3f83241 Tom Herbert          2015-06-04  545  
c3f83241 Tom Herbert          2015-06-04  546  __be32 flow_get_u32_dst(const struct flow_keys *flow)
c3f83241 Tom Herbert          2015-06-04  547  {
c3f83241 Tom Herbert          2015-06-04  548  	switch (flow->control.addr_type) {
c3f83241 Tom Herbert          2015-06-04  549  	case FLOW_DISSECTOR_KEY_IPV4_ADDRS:
c3f83241 Tom Herbert          2015-06-04  550  		return flow->addrs.v4addrs.dst;
c3f83241 Tom Herbert          2015-06-04  551  	case FLOW_DISSECTOR_KEY_IPV6_ADDRS:
c3f83241 Tom Herbert          2015-06-04  552  		return (__force __be32)ipv6_addr_hash(
c3f83241 Tom Herbert          2015-06-04  553  			&flow->addrs.v6addrs.dst);
c3f83241 Tom Herbert          2015-06-04  554  	default:
c3f83241 Tom Herbert          2015-06-04  555  		return 0;
c3f83241 Tom Herbert          2015-06-04  556  	}
c3f83241 Tom Herbert          2015-06-04  557  }
c3f83241 Tom Herbert          2015-06-04  558  EXPORT_SYMBOL(flow_get_u32_dst);
5ed20a68 Tom Herbert          2014-07-01  559  
c3f83241 Tom Herbert          2015-06-04  560  static inline void __flow_hash_consistentify(struct flow_keys *keys)
c3f83241 Tom Herbert          2015-06-04  561  {
c3f83241 Tom Herbert          2015-06-04  562  	int addr_diff, i;
c3f83241 Tom Herbert          2015-06-04  563  
c3f83241 Tom Herbert          2015-06-04  564  	switch (keys->control.addr_type) {
c3f83241 Tom Herbert          2015-06-04  565  	case FLOW_DISSECTOR_KEY_IPV4_ADDRS:
c3f83241 Tom Herbert          2015-06-04  566  		addr_diff = (__force u32)keys->addrs.v4addrs.dst -
c3f83241 Tom Herbert          2015-06-04  567  			    (__force u32)keys->addrs.v4addrs.src;
c3f83241 Tom Herbert          2015-06-04  568  		if ((addr_diff < 0) ||
c3f83241 Tom Herbert          2015-06-04  569  		    (addr_diff == 0 &&
c3f83241 Tom Herbert          2015-06-04  570  		     ((__force u16)keys->ports.dst <
c3f83241 Tom Herbert          2015-06-04  571  		      (__force u16)keys->ports.src))) {
c3f83241 Tom Herbert          2015-06-04  572  			swap(keys->addrs.v4addrs.src, keys->addrs.v4addrs.dst);
c3f83241 Tom Herbert          2015-06-04  573  			swap(keys->ports.src, keys->ports.dst);
c3f83241 Tom Herbert          2015-06-04  574  		}
c3f83241 Tom Herbert          2015-06-04  575  		break;
c3f83241 Tom Herbert          2015-06-04  576  	case FLOW_DISSECTOR_KEY_IPV6_ADDRS:
c3f83241 Tom Herbert          2015-06-04  577  		addr_diff = memcmp(&keys->addrs.v6addrs.dst,
c3f83241 Tom Herbert          2015-06-04  578  				   &keys->addrs.v6addrs.src,
c3f83241 Tom Herbert          2015-06-04  579  				   sizeof(keys->addrs.v6addrs.dst));
c3f83241 Tom Herbert          2015-06-04  580  		if ((addr_diff < 0) ||
c3f83241 Tom Herbert          2015-06-04  581  		    (addr_diff == 0 &&
c3f83241 Tom Herbert          2015-06-04  582  		     ((__force u16)keys->ports.dst <
c3f83241 Tom Herbert          2015-06-04  583  		      (__force u16)keys->ports.src))) {
c3f83241 Tom Herbert          2015-06-04  584  			for (i = 0; i < 4; i++)
c3f83241 Tom Herbert          2015-06-04  585  				swap(keys->addrs.v6addrs.src.s6_addr32[i],
c3f83241 Tom Herbert          2015-06-04  586  				     keys->addrs.v6addrs.dst.s6_addr32[i]);
59346afe Jiri Pirko           2015-05-12  587  			swap(keys->ports.src, keys->ports.dst);
5ed20a68 Tom Herbert          2014-07-01  588  		}
c3f83241 Tom Herbert          2015-06-04  589  		break;
c3f83241 Tom Herbert          2015-06-04  590  	}
c3f83241 Tom Herbert          2015-06-04  591  }
c3f83241 Tom Herbert          2015-06-04  592  
c3f83241 Tom Herbert          2015-06-04  593  static inline u32 __flow_hash_from_keys(struct flow_keys *keys, u32 keyval)
c3f83241 Tom Herbert          2015-06-04  594  {
c3f83241 Tom Herbert          2015-06-04  595  	u32 hash;
c3f83241 Tom Herbert          2015-06-04  596  
c3f83241 Tom Herbert          2015-06-04  597  	__flow_hash_consistentify(keys);
5ed20a68 Tom Herbert          2014-07-01  598  
20a17bf6 David S. Miller      2015-09-01 @599  	hash = __flow_hash_words(flow_keys_hash_start(keys),
42aecaa9 Tom Herbert          2015-06-04  600  				 flow_keys_hash_length(keys), keyval);
5ed20a68 Tom Herbert          2014-07-01  601  	if (!hash)
5ed20a68 Tom Herbert          2014-07-01  602  		hash = 1;

:::::: The code at line 512 was first introduced by commit
:::::: 42aecaa9bb2bd57eb8d61b4565cee5d3640863fb net: Get skb hash over flow_keys structure

:::::: TO: Tom Herbert <tom@herbertland.com>
:::::: CC: David S. Miller <davem@davemloft.net>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--PEIAKu/WMn1b1Hv9
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
M6JUP/zh/yqKj0EffAAA

--PEIAKu/WMn1b1Hv9--
