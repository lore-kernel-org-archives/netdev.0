From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 4/6] arcnet: com20020-pci: add rotary index
 support
Date: Thu, 22 Oct 2015 01:27:29 +0800
Message-ID: <201510220135.3nIResfo%fengguang.wu@intel.com>
References: <1445442332-10625-5-git-send-email-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: Michael Grzeschik <m.grzeschik@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36699 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750844AbbJURYl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 13:24:41 -0400
Content-Disposition: inline
In-Reply-To: <1445442332-10625-5-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

[auto build test WARNING on net-next/master -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Michael-Grzeschik/arcnet-move-dev_free_skb-to-its-only-user/20151021-235034
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/net/arcnet/com20020-pci.c:101:17: sparse: dereference of noderef expression
   drivers/net/arcnet/com20020-pci.c:152:36: sparse: dereference of noderef expression

vim +101 drivers/net/arcnet/com20020-pci.c

    85	
    86		ci = (struct com20020_pci_card_info *)id->driver_data;
    87		priv->ci = ci;
    88		mm = &ci->misc_map;
    89	
    90		INIT_LIST_HEAD(&priv->list_dev);
    91	
    92		if (mm->size) {
    93			ioaddr = pci_resource_start(pdev, mm->bar) + mm->offset;
    94			r = devm_request_region(&pdev->dev, ioaddr, mm->size,
    95						"com20020-pci");
    96			if (!r) {
    97				pr_err("IO region %xh-%xh already allocated.\n",
    98				       ioaddr, ioaddr + mm->size - 1);
    99				return -EBUSY;
   100			}
 > 101			priv->misc = ioaddr;
   102		}
   103	
   104		for (i = 0; i < ci->devcount; i++) {
   105			struct com20020_pci_channel_map *cm = &ci->chan_map_tbl[i];
   106			struct com20020_dev *card;
   107	
   108			dev = alloc_arcdev(device);
   109			if (!dev) {

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
