From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH] net/faraday: Disallow using reversed MAC address from
 hardware
Date: Thu, 21 Jul 2016 11:38:39 +1000
Message-ID: <20160721013839.GA9030@gwshan>
References: <1469064563-7192-1-git-send-email-gwshan@linux.vnet.ibm.com>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	benh@kernel.crashing.org, David.Laight@ACULAB.COM
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:18051 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753219AbcGUBit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 21:38:49 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6L1clU0049651
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 21:38:48 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24a8eyt866-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 21:38:48 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Thu, 21 Jul 2016 11:38:42 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id A43322CE8057
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 11:38:40 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6L1ceCq12910792
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 11:38:40 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6L1cdMp016741
	for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 11:38:40 +1000
Content-Disposition: inline
In-Reply-To: <1469064563-7192-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 21, 2016 at 11:29:23AM +1000, Gavin Shan wrote:
>The initial MAC address is retrieved from hardware if it's not
>provided by device-tree. The reserved MAC address from hardware
>will be used if non-reserved MAC address is invalid. It will
>cause mismatched MAC address seen by hardware and software.
>
>This disallows using the reserved hardware MAC address to avoid
>the mismatched MAC address seen by hardware and software.
>
>Fixes: 113ce107afe9 ("net/faraday: Read MAC address from chip")
>Suggested-by: David Laight <David.Laight@ACULAB.COM>
>Suggested-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
>---

The "net-next" is missed from the subject. I will send a v2 to
fix it. Sorry for the noise.

Thanks,
Gavin

> drivers/net/ethernet/faraday/ftgmac100.c | 9 ---------
> 1 file changed, 9 deletions(-)
>
>diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
>index 2d4c7ea..36361f8 100644
>--- a/drivers/net/ethernet/faraday/ftgmac100.c
>+++ b/drivers/net/ethernet/faraday/ftgmac100.c
>@@ -163,15 +163,6 @@ static void ftgmac100_setup_mac(struct ftgmac100 *priv)
> 	mac[4] = (l >> 8) & 0xff;
> 	mac[5] = l & 0xff;
>
>-	if (!is_valid_ether_addr(mac)) {
>-		mac[5] = (m >> 8) & 0xff;
>-		mac[4] = m & 0xff;
>-		mac[3] = (l >> 24) & 0xff;
>-		mac[2] = (l >> 16) & 0xff;
>-		mac[1] = (l >>  8) & 0xff;
>-		mac[0] = l & 0xff;
>-	}
>-
> 	if (is_valid_ether_addr(mac)) {
> 		ether_addr_copy(priv->netdev->dev_addr, mac);
> 		dev_info(priv->dev, "Read MAC address %pM from chip\n", mac);
>-- 
>2.1.0
>
