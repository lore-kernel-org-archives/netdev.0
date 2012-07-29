From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] seeq: use PTR_RET at init_module of driver
Date: Sun, 29 Jul 2012 23:34:10 +0200
Message-ID: <20120729213410.GA9416@minipsycho.orion>
References: <1343568527-12729-1-git-send-email-develkernel412222@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Howells <dhowells@redhat.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Pradeep A Dalvi <netdev@pradeepdalvi.com>,
	netdev@vger.kernel.org
To: Devendra Naga <develkernel412222@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49175 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753099Ab2G2VeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2012 17:34:15 -0400
Received: by weyx8 with SMTP id x8so3218036wey.19
        for <netdev@vger.kernel.org>; Sun, 29 Jul 2012 14:34:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1343568527-12729-1-git-send-email-develkernel412222@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jul 29, 2012 at 03:28:47PM CEST, develkernel412222@gmail.com wrote:
>the driver sees wether the dev_seeq pointer is having a error that can be
>read by using the PTR_ERR, and returns it at error case, other wise 0 at
>success case.
>
>the PTR_RET does the same thing, and use PTR_RET instead of redoing the
>code of PTR_RET
>
>Signed-off-by: Devendra Naga <develkernel412222@gmail.com>
>---
>This patch is actually made by using coccinelle, and also by looking
>at the PTR_RET function.
>
>as its implementation is
>static int PTR_RET(void *ptr)
>{
>	if (IS_ERR(ptr)
>		return PTR_ERR(ptr);
>	return 0;
>}
>
>by using this i removed the following code and replaced with PTR_RET....
>
>
> drivers/net/ethernet/seeq/seeq8005.c |    4 +---
> 1 file changed, 1 insertion(+), 3 deletions(-)
>
>diff --git a/drivers/net/ethernet/seeq/seeq8005.c b/drivers/net/ethernet/seeq/seeq8005.c
>index 698edbb..d6e50de 100644
>--- a/drivers/net/ethernet/seeq/seeq8005.c
>+++ b/drivers/net/ethernet/seeq/seeq8005.c
>@@ -736,9 +736,7 @@ MODULE_PARM_DESC(irq, "SEEQ 8005 IRQ number");
> int __init init_module(void)
> {
> 	dev_seeq = seeq8005_probe(-1);
>-	if (IS_ERR(dev_seeq))
>-		return PTR_ERR(dev_seeq);
>-	return 0;
>+	return PTR_RET(dev_seeq);
> }
> 
> void __exit cleanup_module(void)
>-- 
>1.7.9.5
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html


Reviewed-by: Jiri Pirko <jiri@resnulli.us>
