From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] cxgb4: remove workqueue when driver registration fails
Date: Sun, 15 Sep 2013 21:58:19 +0800
Message-ID: <20130915135819.GA10479@weiyang.vnet.ibm.com>
References: <1379253180-10292-1-git-send-email-weiyang@linux.vnet.ibm.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dm@chelsio.com, netdev@vger.kernel.org, davem@davemloft.net
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:48621 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756541Ab3ION60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Sep 2013 09:58:26 -0400
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Sun, 15 Sep 2013 19:21:56 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id B6E87E0055
	for <netdev@vger.kernel.org>; Sun, 15 Sep 2013 19:29:16 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8FE0SL141680954
	for <netdev@vger.kernel.org>; Sun, 15 Sep 2013 19:30:28 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8FDwKwc010311
	for <netdev@vger.kernel.org>; Sun, 15 Sep 2013 19:28:21 +0530
Content-Disposition: inline
In-Reply-To: <1379253180-10292-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This time, I cc-ed to myself. And this applies to the latest net tree.

It looks not corrupted to me. Not sure other people can see it clearly? 

On Sun, Sep 15, 2013 at 09:53:00PM +0800, Wei Yang wrote:
>When driver registration fails, we need to clean up the resources allocated
>before. cxgb4 missed to destroy the workqueue allocated at the very beginning.
>
>This patch destroies the workqueue when registration fails.
>
>Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>---
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    4 +++-
> 1 files changed, 3 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
>index 0d0665c..c73cabd 100644
>--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
>+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
>@@ -6149,8 +6149,10 @@ static int __init cxgb4_init_module(void)
> 		pr_warn("could not create debugfs entry, continuing\n");
>
> 	ret = pci_register_driver(&cxgb4_driver);
>-	if (ret < 0)
>+	if (ret < 0) {
> 		debugfs_remove(cxgb4_debugfs_root);
>+		destroy_workqueue(workq);
>+	}
>
> 	register_inet6addr_notifier(&cxgb4_inet6addr_notifier);
>
>-- 
>1.7.1
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Richard Yang
Help you, Help me
