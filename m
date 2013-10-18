From: "Neel Patel (neepatel)" <neepatel@cisco.com>
Subject: RE: [PATCH 15/15] net: enic: remove unnecessary pci_set_drvdata()
Date: Fri, 18 Oct 2013 16:00:06 +0000
Message-ID: <644DFB2E795E0348A1614A34EE0D357118496461@xmb-rcd-x05.cisco.com>
References: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
 <00be01cecb98$8cabcd20$a6036760$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Christian Benvenuti (benve)" <benve@cisco.com>,
	"Sujith Sankar (ssujith)" <ssujith@cisco.com>,
	"'Govindarajulu Varadarajan'" <govindarajulu90@gmail.com>,
	"Nishank Trivedi (nistrive)" <nistrive@cisco.com>
To: Jingoo Han <jg1.han@samsung.com>,
	"'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-2.cisco.com ([173.37.86.73]:40883 "EHLO
	rcdn-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756369Ab3JRQAK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 12:00:10 -0400
In-Reply-To: <00be01cecb98$8cabcd20$a6036760$%han@samsung.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks good.

-----Original Message-----
From: Jingoo Han [mailto:jg1.han@samsung.com] 
Sent: Thursday, October 17, 2013 5:25 PM
To: 'David S. Miller'
Cc: netdev@vger.kernel.org; 'Jingoo Han'; Christian Benvenuti (benve); Sujith Sankar (ssujith); 'Govindarajulu Varadarajan'; Neel Patel (neepatel); Nishank Trivedi (nistrive)
Subject: [PATCH 15/15] net: enic: remove unnecessary pci_set_drvdata()

The driver core clears the driver data to NULL after device_release or on probe failure. Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 7b756cf9..ff78dfa 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2309,7 +2309,6 @@ err_out_release_regions:
 err_out_disable_device:
 	pci_disable_device(pdev);
 err_out_free_netdev:
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
 
 	return err;
@@ -2338,7 +2337,6 @@ static void enic_remove(struct pci_dev *pdev)
 		enic_iounmap(enic);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
 		free_netdev(netdev);
 	}
 }
--
1.7.10.4
