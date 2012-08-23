From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] wimax/i2400m: use is_zero_ether_addr() instead of memcmp()
Date: Thu, 23 Aug 2012 14:49:33 +0800
Message-ID: <CAPgLHd9_MkQcGbQEqf=6Kjm06juybu29qSBdd7T=_EenFDyuEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-wimax@intel.com,
	wimax@linuxwimax.org, netdev@vger.kernel.org
To: inaky.perez-gonzalez@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:32860 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755486Ab2HWGte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 02:49:34 -0400
Received: by qaas11 with SMTP id s11so398072qaa.19
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 23:49:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using is_zero_ether_addr() instead of directly use
memcmp() to determine if the ethernet address is all
zeros.

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/wimax/i2400m/driver.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 0254261..9c34d2f 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -222,7 +222,6 @@ int i2400m_check_mac_addr(struct i2400m *i2400m)
 	struct sk_buff *skb;
 	const struct i2400m_tlv_detailed_device_info *ddi;
 	struct net_device *net_dev = i2400m->wimax_dev.net_dev;
-	const unsigned char zeromac[ETH_ALEN] = { 0 };
 
 	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
 	skb = i2400m_get_device_info(i2400m);
@@ -244,7 +243,7 @@ int i2400m_check_mac_addr(struct i2400m *i2400m)
 		 "to that of boot mode's\n");
 	dev_warn(dev, "device reports     %pM\n", ddi->mac_address);
 	dev_warn(dev, "boot mode reported %pM\n", net_dev->perm_addr);
-	if (!memcmp(zeromac, ddi->mac_address, sizeof(zeromac)))
+	if (is_zero_ether_addr(ddi->mac_address))
 		dev_err(dev, "device reports an invalid MAC address, "
 			"not updating\n");
 	else {
