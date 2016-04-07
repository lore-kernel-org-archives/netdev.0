From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 207/208] net/tipc/bearer.c:560:48: sparse:
 incompatible types in comparison expression (different base types)
Date: Fri, 8 Apr 2016 06:10:39 +0800
Message-ID: <201604080619.siIBpIBY%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: Jon Paul Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42941 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752366AbcDGWL7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 18:11:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   889750bd2e08a94d52a116056d462b3a8e5616a7
commit: 5b7066c3dd24c7d538e5ee402eb24bb182c16dab [207/208] tipc: stricter filtering of packets in bearer layer
reproduce:
        # apt-get install sparse
        git checkout 5b7066c3dd24c7d538e5ee402eb24bb182c16dab
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/compiler.h:232:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> net/tipc/bearer.c:560:48: sparse: incompatible types in comparison expression (different base types)

vim +560 net/tipc/bearer.c

   544	 * This function is called by the Ethernet driver in case of link
   545	 * change event.
   546	 */
   547	static int tipc_l2_device_event(struct notifier_block *nb, unsigned long evt,
   548					void *ptr)
   549	{
   550		struct net_device *dev = netdev_notifier_info_to_dev(ptr);
   551		struct net *net = dev_net(dev);
   552		struct tipc_net *tn = tipc_net(net);
   553		struct tipc_bearer *b;
   554		int i;
   555	
   556		b = rtnl_dereference(dev->tipc_ptr);
   557		if (!b) {
   558			for (i = 0; i < MAX_BEARERS; b = NULL, i++) {
   559				b = rtnl_dereference(tn->bearer_list[i]);
 > 560				if (b && (b->media_ptr == dev))
   561					break;
   562			}
   563		}
   564		if (!b)
   565			return NOTIFY_DONE;
   566	
   567		b->mtu = dev->mtu;
   568	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
