From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 386/609] include/net/vxlan.h:302:17: sparse: cast
 to restricted __be64
Date: Sat, 19 Mar 2016 08:57:53 +0800
Message-ID: <201603190849.15c8JxPc%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15301 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751538AbcCSA60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 20:58:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   93e68cd6115f67d8363c94dae8206af36f6d3b00
commit: 07dabf20d9867710b90b91108b2adcd448773e25 [386/609] vxlan: tun_id is 64bit, not 32bit
reproduce:
        # apt-get install sparse
        git checkout 07dabf20d9867710b90b91108b2adcd448773e25
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/net/checksum.h:177:43: sparse: incorrect type in argument 2 (different base types)
   include/net/checksum.h:177:43:    expected restricted __wsum [usertype] addend
   include/net/checksum.h:177:43:    got restricted __sum16 [usertype] <noident>
   include/net/inet_ecn.h:131:58: sparse: incorrect type in argument 2 (different base types)
   include/net/inet_ecn.h:131:58:    expected restricted __wsum [usertype] addend
   include/net/inet_ecn.h:131:58:    got restricted __be32 [assigned] [usertype] from
   include/net/inet_ecn.h:131:65: sparse: incorrect type in argument 2 (different base types)
   include/net/inet_ecn.h:131:65:    expected restricted __wsum [usertype] addend
   include/net/inet_ecn.h:131:65:    got restricted __be32 [assigned] [usertype] to
   include/net/inet_ecn.h:131:58: sparse: incorrect type in argument 2 (different base types)
   include/net/inet_ecn.h:131:58:    expected restricted __wsum [usertype] addend
   include/net/inet_ecn.h:131:58:    got restricted __be32 [assigned] [usertype] from
   include/net/inet_ecn.h:131:65: sparse: incorrect type in argument 2 (different base types)
   include/net/inet_ecn.h:131:65:    expected restricted __wsum [usertype] addend
   include/net/inet_ecn.h:131:65:    got restricted __be32 [assigned] [usertype] to
   include/net/vxlan.h:275:27: sparse: restricted __be32 degrades to integer
   include/net/vxlan.h:275:45: sparse: incorrect type in return expression (different base types)
   include/net/vxlan.h:275:45:    expected restricted __be32
   include/net/vxlan.h:275:45:    got unsigned int
>> include/net/vxlan.h:302:17: sparse: cast to restricted __be64
>> include/net/vxlan.h:302:17: sparse: cast from restricted __be32
   include/net/vxlan.h:302:17: sparse: restricted __be64 degrades to integer
>> include/net/vxlan.h:302:28: sparse: incorrect type in return expression (different base types)
   include/net/vxlan.h:302:28:    expected restricted __be64
   include/net/vxlan.h:302:28:    got unsigned long long
   include/net/vxlan.h:275:27: sparse: restricted __be32 degrades to integer
   include/net/vxlan.h:275:45: sparse: incorrect type in return expression (different base types)
   include/net/vxlan.h:275:45:    expected restricted __be32
   include/net/vxlan.h:275:45:    got unsigned int
   include/net/vxlan.h:284:16: sparse: restricted __be32 degrades to integer
   include/net/vxlan.h:284:20: sparse: incorrect type in return expression (different base types)
   include/net/vxlan.h:284:20:    expected restricted __be32
   include/net/vxlan.h:284:20:    got unsigned int
   include/net/vxlan.h:293:16: sparse: restricted __be64 degrades to integer
   include/net/vxlan.h:293:23: sparse: incorrect type in return expression (different base types)
   include/net/vxlan.h:293:23:    expected restricted __be32
   include/net/vxlan.h:293:23:    got unsigned long long

vim +302 include/net/vxlan.h

   269	
   270	static inline __be32 vxlan_vni(__be32 vni_field)
   271	{
   272	#if defined(__BIG_ENDIAN)
   273		return vni_field >> 8;
   274	#else
 > 275		return (vni_field & VXLAN_VNI_MASK) << 8;
   276	#endif
   277	}
   278	
   279	static inline __be32 vxlan_vni_field(__be32 vni)
   280	{
   281	#if defined(__BIG_ENDIAN)
   282		return vni << 8;
   283	#else
   284		return vni >> 8;
   285	#endif
   286	}
   287	
   288	static inline __be32 vxlan_tun_id_to_vni(__be64 tun_id)
   289	{
   290	#if defined(__BIG_ENDIAN)
   291		return tun_id;
   292	#else
   293		return tun_id >> 32;
   294	#endif
   295	}
   296	
   297	static inline __be64 vxlan_vni_to_tun_id(__be32 vni)
   298	{
   299	#if defined(__BIG_ENDIAN)
   300		return (__be64)vni;
   301	#else
 > 302		return (__be64)vni << 32;
   303	#endif
   304	}
   305	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
