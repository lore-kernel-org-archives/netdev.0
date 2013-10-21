From: "Sujith Sankar (ssujith)" <ssujith@cisco.com>
Subject: Re: [PATCH 15/15] net: enic: remove unnecessary pci_set_drvdata()
Date: Mon, 21 Oct 2013 14:02:38 +0000
Message-ID: <9C4CB4066E545D4D9D728B3238E19CA5014B62CE@xmb-aln-x07.cisco.com>
References: <00be01cecb98$8cabcd20$a6036760$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Christian Benvenuti (benve)" <benve@cisco.com>,
	"'Govindarajulu Varadarajan'" <govindarajulu90@gmail.com>,
	"Neel Patel (neepatel)" <neepatel@cisco.com>
To: Jingoo Han <jg1.han@samsung.com>,
	"'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-2.cisco.com ([173.37.86.73]:36322 "EHLO
	rcdn-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753785Ab3JUOCk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 10:02:40 -0400
In-Reply-To: <00be01cecb98$8cabcd20$a6036760$%han@samsung.com>
Content-Language: en-US
Content-ID: <BEA60837B5BB79449B73F0272C517B45@emea.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This looks good to me.

Regards,
-Sujith

On 18/10/13 5:55 AM, "Jingoo Han" <jg1.han@samsung.com> wrote:

>The driver core clears the driver data to NULL after device_release
>or on probe failure. Thus, it is not needed to manually clear the
>device driver data to NULL.
>
>Signed-off-by: Jingoo Han <jg1.han@samsung.com>
>---
> drivers/net/ethernet/cisco/enic/enic_main.c |    2 --
> 1 file changed, 2 deletions(-)
>
>diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c
>b/drivers/net/ethernet/cisco/enic/enic_main.c
>index 7b756cf9..ff78dfa 100644
>--- a/drivers/net/ethernet/cisco/enic/enic_main.c
>+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
>@@ -2309,7 +2309,6 @@ err_out_release_regions:
> err_out_disable_device:
> 	pci_disable_device(pdev);
> err_out_free_netdev:
>-	pci_set_drvdata(pdev, NULL);
> 	free_netdev(netdev);
> 
> 	return err;
>@@ -2338,7 +2337,6 @@ static void enic_remove(struct pci_dev *pdev)
> 		enic_iounmap(enic);
> 		pci_release_regions(pdev);
> 		pci_disable_device(pdev);
>-		pci_set_drvdata(pdev, NULL);
> 		free_netdev(netdev);
> 	}
> }
>-- 
>1.7.10.4
>
>
