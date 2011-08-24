From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [patch -next] bna: unlock on error path in pnad_pci_probe()
Date: Wed, 24 Aug 2011 10:25:45 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A9E4B8C4DE@HQ1-EXCH01.corp.brocade.com>
References: <20110824112922.GC5975@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Debashis Dutt <ddutt@brocade.com>,
	"open list:BROCADE BNA 10 GI..." <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Jing Huang <huangj@Brocade.COM>
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:36348 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752488Ab1HXRZw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 13:25:52 -0400
In-Reply-To: <20110824112922.GC5975@shale.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Dan Carpenter [mailto:error27@gmail.com]
>Sent: Wednesday, August 24, 2011 4:29 AM
>
>We introduced a new lock here, so there was error path which needs
>an unlock now.
>
>Signed-off-by: Dan Carpenter <error27@gmail.com>
>
>diff --git a/drivers/net/ethernet/brocade/bna/bnad.c
>b/drivers/net/ethernet/brocade/bna/bnad.c
>index bdfda07..6ad4b47 100644
>--- a/drivers/net/ethernet/brocade/bna/bnad.c
>+++ b/drivers/net/ethernet/brocade/bna/bnad.c
>@@ -3167,7 +3167,7 @@ bnad_pci_probe(struct pci_dev *pdev,
> 	 */
> 	err = bnad_pci_init(bnad, pdev, &using_dac);
> 	if (err)
>-		goto free_netdev;
>+		goto unlock_mutex;
>
> 	/*
> 	 * Initialize bnad structure
>@@ -3296,9 +3296,9 @@ drv_uninit:
> 	bnad_uninit(bnad);
> pci_uninit:
> 	bnad_pci_uninit(pdev);
>+unlock_mutex:
> 	mutex_unlock(&bnad->conf_mutex);
> 	bnad_lock_uninit(bnad);
>-free_netdev:
> 	free_netdev(netdev);
> 	return err;
> }

Acked-by: Rasesh Mody <rmody@brocade.com>

Thanks,
Rasesh
