From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 200/208] drivers/net/vxlan.c:1739:21: sparse:
 incorrect type in assignment (different base types)
Date: Wed, 22 Jul 2015 09:18:10 +0800
Message-ID: <201507220908.ME7fvS0Z%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, Pravin B Shelar <pshelar@nicira.com>,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27543 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934139AbbGVBTm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2015 21:19:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   16040894b26af9f85d9395f072c53d76a44eba21
commit: 614732eaa12dd462c0ab274700bed14f36afea5e [200/208] openvswitch: Use regular VXLAN net_device device
reproduce:
  # apt-get install sparse
  git checkout 614732eaa12dd462c0ab274700bed14f36afea5e
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/net/checksum.h:166:35: sparse: incorrect type in argument 1 (different base types)
   include/net/checksum.h:166:35:    expected restricted __wsum [usertype] csum
   include/net/checksum.h:166:35:    got restricted __sum16
   include/net/checksum.h:166:43: sparse: incorrect type in argument 2 (different base types)
   include/net/checksum.h:166:43:    expected restricted __wsum [usertype] addend
   include/net/checksum.h:166:43:    got restricted __sum16 [usertype] <noident>
   include/net/checksum.h:174:43: sparse: incorrect type in argument 2 (different base types)
   include/net/checksum.h:174:43:    expected restricted __wsum [usertype] addend
   include/net/checksum.h:174:43:    got restricted __sum16 [usertype] <noident>
   include/net/checksum.h:166:35: sparse: incorrect type in argument 1 (different base types)
   include/net/checksum.h:166:35:    expected restricted __wsum [usertype] csum
   include/net/checksum.h:166:35:    got restricted __sum16
   include/net/checksum.h:166:43: sparse: incorrect type in argument 2 (different base types)
   include/net/checksum.h:166:43:    expected restricted __wsum [usertype] addend
   include/net/checksum.h:166:43:    got restricted __sum16 [usertype] <noident>
>> drivers/net/vxlan.c:1739:21: sparse: incorrect type in assignment (different base types)
   drivers/net/vxlan.c:1739:21:    expected restricted __be32 [usertype] vx_vni
   drivers/net/vxlan.c:1739:21:    got unsigned int [unsigned] [usertype] vni
   drivers/net/vxlan.c:1818:21: sparse: incorrect type in assignment (different base types)
   drivers/net/vxlan.c:1818:21:    expected restricted __be32 [usertype] vx_vni
   drivers/net/vxlan.c:1818:21:    got unsigned int [unsigned] [usertype] vni
>> drivers/net/vxlan.c:2014:58: sparse: incorrect type in argument 11 (different base types)
   drivers/net/vxlan.c:2014:58:    expected unsigned int [unsigned] [usertype] vni
   drivers/net/vxlan.c:2014:58:    got restricted __be32 [usertype] <noident>
   drivers/net/vxlan.c:2072:67: sparse: incorrect type in argument 11 (different base types)
   drivers/net/vxlan.c:2072:67:    expected unsigned int [unsigned] [usertype] vni
   drivers/net/vxlan.c:2072:67:    got restricted __be32 [usertype] <noident>

vim +1739 drivers/net/vxlan.c

  1723		}
  1724	
  1725		skb = vlan_hwaccel_push_inside(skb);
  1726		if (WARN_ON(!skb)) {
  1727			err = -ENOMEM;
  1728			goto err;
  1729		}
  1730	
  1731		skb = iptunnel_handle_offloads(skb, udp_sum, type);
  1732		if (IS_ERR(skb)) {
  1733			err = -EINVAL;
  1734			goto err;
  1735		}
  1736	
  1737		vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
  1738		vxh->vx_flags = htonl(VXLAN_HF_VNI);
> 1739		vxh->vx_vni = vni;
  1740	
  1741		if (type & SKB_GSO_TUNNEL_REMCSUM) {
  1742			u32 data = (skb_checksum_start_offset(skb) - hdrlen) >>
  1743				   VXLAN_RCO_SHIFT;
  1744	
  1745			if (skb->csum_offset == offsetof(struct udphdr, check))
  1746				data |= VXLAN_RCO_UDP;
  1747	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
