From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: Re: [PATCH] qlge: add missing free_netdev() on error in qlge_probe()
Date: Thu, 23 May 2013 14:40:46 +0000
Message-ID: <BECD8E8A1B550B48A1BF97C13991F60E32A4FE@avmb2.qlogic.org>
References: <CAPgLHd-8NxBN2-x2zzjgbVNj4E_4bhVqdTi1HmxMh5pawXPKZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "yongjun_wei@trendmicro.com.cn" <yongjun_wei@trendmicro.com.cn>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:13639
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758967Ab3EWOky convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 10:40:54 -0400
In-Reply-To: <CAPgLHd-8NxBN2-x2zzjgbVNj4E_4bhVqdTi1HmxMh5pawXPKZA@mail.gmail.com>
Content-Language: en-US
Content-ID: <2F7E78FA49261B4E8F5D41E250B1E199@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/23/13 2:09 AM, "Wei Yongjun" <weiyj.lk@gmail.com> wrote:

>From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
>Add the missing free_netdev() before return from function
>qlge_probe() in the error handling case.
>
>Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>---
> drivers/net/ethernet/qlogic/qlge/qlge_main.c | 1 +
> 1 file changed, 1 insertion(+)
>
>diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
>b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
>index e04d471..2553cf4 100644
>--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
>+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
>@@ -4717,6 +4717,7 @@ static int qlge_probe(struct pci_dev *pdev,
> 		dev_err(&pdev->dev, "net device registration failed.\n");
> 		ql_release_all(pdev);
> 		pci_disable_device(pdev);
>+		free_netdev(ndev);
> 		return err;
> 	}
> 	/* Start up the timer to trigger EEH if

Thanks!

Acked-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
