From: David Miller <davem@davemloft.net>
Subject: Re: next-20170608 build: 1 failures 4 warnings (next-20170608)
Date: Thu, 08 Jun 2017 10:16:27 -0400 (EDT)
Message-ID: <20170608.101627.1876505383531574064.davem@davemloft.net>
References: <E1dIuCM-0000cQ-QM@optimist>
        <20170608202704.1469d0bf@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, broonie@kernel.org,
        linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56662 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751543AbdFHOQ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 10:16:29 -0400
In-Reply-To: <20170608202704.1469d0bf@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 8 Jun 2017 20:27:04 +1000

> Hi Dave,
> 
> On Thu, 08 Jun 2017 10:57:50 +0100 Build bot for Mark Brown <broonie@kernel.org> wrote:
>>
>> Tree/Branch: next-20170608
>> Git describe: next-20170608
>> Commit: e4689b9aad Add linux-next specific files for 20170608
>> 
>> Build Time: 0 min 12 sec
>> 
>> Passed:    6 / 7   ( 85.71 %)
>> Failed:    1 / 7   ( 14.29 %)
>> 
>> Errors: 1
>> Warnings: 4
>> Section Mismatches: 0
>> 
>> Failed defconfigs:
>> 	arm-allmodconfig
>> 
>> Errors:
>> 
>> 	arm-allmodconfig
>> ../drivers/hsi/clients/ssi_protocol.c:1069:5: error: 'struct net_device' has no member named 'destructor'
> 
> Looks like Mark has found another one.

This should fix it, pushed out to 'net'.

Thanks.

====================
[PATCH] hsi: Fix build regression due to netdev destructor fix.

> ../drivers/hsi/clients/ssi_protocol.c:1069:5: error: 'struct net_device' has no member named 'destructor'

Reported-by: Mark Brown <broonie@kernel.org>
Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/hsi/clients/ssi_protocol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/hsi/clients/ssi_protocol.c b/drivers/hsi/clients/ssi_protocol.c
index 26b0510..93d28c0 100644
--- a/drivers/hsi/clients/ssi_protocol.c
+++ b/drivers/hsi/clients/ssi_protocol.c
@@ -1066,7 +1066,7 @@ static void ssip_pn_setup(struct net_device *dev)
 	dev->addr_len		= 1;
 	dev->tx_queue_len	= SSIP_TXQUEUE_LEN;
 
-	dev->destructor		= free_netdev;
+	dev->needs_free_netdev	= true;
 	dev->header_ops		= &phonet_header_ops;
 }
 
-- 
2.4.11
