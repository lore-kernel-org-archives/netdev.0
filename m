From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 894/905]
 drivers/net/ethernet/cisco/enic/vnic_dev.c:1095:13: sparse: incorrect type
 in assignment (different address spaces)
Date: Tue, 18 Aug 2015 09:07:32 +0800
Message-ID: <201508180929.kFax186R%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, N V V Satyanarayana Reddy <nalreddy@cisco.com>,
	netdev@vger.kernel.org
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:17775 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011AbbHRBEU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 21:04:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   9cd3778cd7e8f165675705511cfcd4ea6eb88d27
commit: 373fb0873d4325a7afa04aec29ced0c122d1f8a9 [894/905] enic: add devcmd2
reproduce:
  # apt-get install sparse
  git checkout 373fb0873d4325a7afa04aec29ced0c122d1f8a9
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/cisco/enic/vnic_dev.c:1095:13: sparse: incorrect type in assignment (different address spaces)
   drivers/net/ethernet/cisco/enic/vnic_dev.c:1095:13:    expected void *res
   drivers/net/ethernet/cisco/enic/vnic_dev.c:1095:13:    got void [noderef] <asn:2>*

vim +1095 drivers/net/ethernet/cisco/enic/vnic_dev.c

  1079		vnic_dev_unregister(vdev);
  1080		return NULL;
  1081	}
  1082	EXPORT_SYMBOL(vnic_dev_register);
  1083	
  1084	struct pci_dev *vnic_dev_get_pdev(struct vnic_dev *vdev)
  1085	{
  1086		return vdev->pdev;
  1087	}
  1088	EXPORT_SYMBOL(vnic_dev_get_pdev);
  1089	
  1090	int vnic_devcmd_init(struct vnic_dev *vdev)
  1091	{
  1092		int err;
  1093		void *res;
  1094	
> 1095		res = vnic_dev_get_res(vdev, RES_TYPE_DEVCMD2, 0);
  1096		if (res) {
  1097			err = vnic_dev_init_devcmd2(vdev);
  1098			if (err)
  1099				vdev_warn("DEVCMD2 init failed: %d, Using DEVCMD1",
  1100					  err);
  1101			else
  1102				return 0;
  1103		} else {

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
