From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 1118/1134]
 drivers/net/dsa/b53/b53_srab.c:388:20: warning: cast from pointer to
 integer of different size
Date: Mon, 11 Jul 2016 14:31:25 -0700 (PDT)
Message-ID: <20160711.143125.685534519604579905.davem@davemloft.net>
References: <201607120549.q93JxhcC%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org, f.fainelli@gmail.com
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036AbcGKVb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 17:31:27 -0400
In-Reply-To: <201607120549.q93JxhcC%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Tue, 12 Jul 2016 05:19:57 +0800

> All warnings (new ones prefixed by >>):
> 
>    drivers/net/dsa/b53/b53_srab.c: In function 'b53_srab_probe':
>>> drivers/net/dsa/b53/b53_srab.c:388:20: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
>       pdata->chip_id = (u32)of_id->data;
>                        ^
> 

Fixed as follows:

====================
[PATCH] b53: Fix build warning.

   drivers/net/dsa/b53/b53_srab.c: In function 'b53_srab_probe':
>> drivers/net/dsa/b53/b53_srab.c:388:20: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
      pdata->chip_id = (u32)of_id->data;
                       ^

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/dsa/b53/b53_srab.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/b53/b53_srab.c b/drivers/net/dsa/b53/b53_srab.c
index 2b304ea..3e2d4a5 100644
--- a/drivers/net/dsa/b53/b53_srab.c
+++ b/drivers/net/dsa/b53/b53_srab.c
@@ -393,7 +393,7 @@ static int b53_srab_probe(struct platform_device *pdev)
 		if (!pdata)
 			return -ENOMEM;
 
-		pdata->chip_id = (u32)of_id->data;
+		pdata->chip_id = (u32)(unsigned long)of_id->data;
 	}
 
 	priv = devm_kzalloc(&pdev->dev, sizeof(*priv), GFP_KERNEL);
-- 
2.1.0
