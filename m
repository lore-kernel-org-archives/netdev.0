From: "Ruinskiy, Dima" <dima.ruinskiy@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] e1000e: free IRQ when the link is up
 or     down
Date: Thu, 3 Nov 2016 08:09:27 +0000
Message-ID: <36CDDD56DDB4D44E911123902EFC26B06CD48342@HASMSX110.ger.corp.intel.com>
References: <1478120896-5907-1-git-send-email-tbaicar@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Tyler Baicar <tbaicar@codeaurora.org>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "okaya@codeaurora.org" <okaya@codeaurora.org>,
        "timur@codeaurora.org" <timur@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478120896-5907-1-git-send-email-tbaicar@codeaurora.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
>Behalf Of Tyler Baicar
>Sent: Wednesday, 02 November, 2016 23:08
>To: Kirsher, Jeffrey T; intel-wired-lan@lists.osuosl.org;
>netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
>okaya@codeaurora.org; timur@codeaurora.org
>Cc: Tyler Baicar
>Subject: [Intel-wired-lan] [PATCH] e1000e: free IRQ when the link is up or
>down
>
>Move IRQ free code so that it will happen regardless of the link state.
>Currently the e1000e driver only releases its IRQ if the link is up. This is not
>sufficient because it is possible for a link to go down without releasing the IRQ.
>A secondary bus reset can cause this case to happen.
>
>Signed-off-by: Tyler Baicar <tbaicar@codeaurora.org>
>---
> drivers/net/ethernet/intel/e1000e/netdev.c | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
>
>diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
>b/drivers/net/ethernet/intel/e1000e/netdev.c
>index 7017281..36cfcb0 100644
>--- a/drivers/net/ethernet/intel/e1000e/netdev.c
>+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
>@@ -4679,12 +4679,13 @@ int e1000e_close(struct net_device *netdev)
>
> 	if (!test_bit(__E1000_DOWN, &adapter->state)) {
> 		e1000e_down(adapter, true);
>-		e1000_free_irq(adapter);
>
> 		/* Link status message must follow this format */
> 		pr_info("%s NIC Link is Down\n", adapter->netdev->name);
> 	}
>
>+	e1000_free_irq(adapter);
>+
> 	napi_disable(&adapter->napi);
>
> 	e1000e_free_tx_resources(adapter->tx_ring);
>--
>Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
>Technologies, Inc.
>Qualcomm Technologies, Inc. is a member of the Code Aurora Forum, a Linux
>Foundation Collaborative Project.
>
>_______________________________________________
>Intel-wired-lan mailing list
>Intel-wired-lan@lists.osuosl.org
>http://lists.osuosl.org/mailman/listinfo/intel-wired-lan

This is not correct. __E1000_DOWN has nothing to do with link state. It is an internal driver status bit that indicates that device shutdown is in progress.

I would not change this code without checking very carefully the driver state machine. This can cause a whole lot of issues. Did you encounter some particular problem that is resolved by this change?
---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
