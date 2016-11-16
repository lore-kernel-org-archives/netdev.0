From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net: ethernet: faraday: To support device tree usage.
Date: Wed, 16 Nov 2016 12:53:43 +0100
Message-ID: <20161116115343.GB1791@nanopsycho.orion>
References: <1479285795-3105-1-git-send-email-green.hu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Greentime Hu <green.hu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33590 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbcKPLxq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 06:53:46 -0500
Received: by mail-wm0-f65.google.com with SMTP id u144so10282970wmu.0
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 03:53:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1479285795-3105-1-git-send-email-green.hu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 16, 2016 at 09:43:15AM CET, green.hu@gmail.com wrote:
>To support device tree usage for ftmac100.
>
>Signed-off-by: Greentime Hu <green.hu@gmail.com>
>---
> drivers/net/ethernet/faraday/ftmac100.c |    7 +++++++
> 1 file changed, 7 insertions(+)
>
>diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
>index dce5f7b..81dd9e1 100644
>--- a/drivers/net/ethernet/faraday/ftmac100.c
>+++ b/drivers/net/ethernet/faraday/ftmac100.c
>@@ -1172,11 +1172,17 @@ static int __exit ftmac100_remove(struct platform_device *pdev)
> 	return 0;
> }
> 
>+static const struct of_device_id mac_of_ids[] = {

Prefix of everything in this file is "ftmac100", yet here, you use
"mac". I wonder why?!?



>+	{ .compatible = "andestech,atmac100" },
>+	{ }
>+};
>+
> static struct platform_driver ftmac100_driver = {
> 	.probe		= ftmac100_probe,
> 	.remove		= __exit_p(ftmac100_remove),
> 	.driver		= {
> 		.name	= DRV_NAME,
>+		.of_match_table = mac_of_ids
> 	},
> };
> 
>@@ -1200,3 +1206,4 @@ static void __exit ftmac100_exit(void)
> MODULE_AUTHOR("Po-Yu Chuang <ratbert@faraday-tech.com>");
> MODULE_DESCRIPTION("FTMAC100 driver");
> MODULE_LICENSE("GPL");
>+MODULE_DEVICE_TABLE(of, mac_of_ids);
>-- 
>1.7.9.5
>
