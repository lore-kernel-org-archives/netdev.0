From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [hyperv] BUG: unable to handle kernel paging request at
 ffff8801f5bc7cbb (netvsc_select_queue)
Date: Fri, 29 Aug 2014 17:18:51 +0000
Message-ID: <9b92bf4b20ea4fe7a6be0072e738da3c@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <20140829093141.GC11445@sucs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>
To: Sitsofe Wheeler <sitsofe@gmail.com>,
	Dexuan Cui <decui@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140829093141.GC11445@sucs.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Sitsofe Wheeler [mailto:sitsofe@gmail.com]
> Sent: Friday, August 29, 2014 2:32 AM
> To: Dexuan Cui
> Cc: KY Srinivasan; Greg Kroah-Hartman; Haiyang Zhang;
> devel@linuxdriverproject.org; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org; David Miller; Daniel Borkmann
> Subject: [hyperv] BUG: unable to handle kernel paging request at
> ffff8801f5bc7cbb (netvsc_select_queue)
> 
> While booting a 10 vcpu system with a post v3.17-rc2 kernel with the
> "Drivers: hv: vmbus: Eliminate calls to BUG_ON()",  "Drivers: hv: vmbus:
> Miscellaneous cleanup" patches and debugging/verification config options on
> I'm seeing the following:

Sitsofe,

Could you please try the following patch:

>From c8a6a5570f9a7f8b9a2b47f165848e5533091e79 Mon Sep 17 00:00:00 2001
From: K. Y. Srinivasan <kys@microsoft.com>
Date: Fri, 29 Aug 2014 11:18:18 -0700
Subject: [PATCH 1/1] Drivers: net: hyperv: Cleanup  netvsc_change_mtu ()


Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index a9c5eaa..485f5b7 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -696,6 +696,7 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
        struct netvsc_device *nvdev = hv_get_drvdata(hdev);
        struct netvsc_device_info device_info;
        int limit = ETH_DATA_LEN;
+       int ret;

        if (nvdev == NULL || nvdev->destroy)
                return -ENODEV;
@@ -716,7 +717,9 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
        ndevctx->device_ctx = hdev;
        hv_set_drvdata(hdev, ndev);
        device_info.ring_size = ring_size;
-       rndis_filter_device_add(hdev, &device_info);
+       ret = rndis_filter_device_add(hdev, &device_info);
+       if (ret)
+               return ret;
        netif_tx_wake_all_queues(ndev);

        return 0;
--
1.7.4.1
