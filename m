From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] stmmac: new descriptor field for the driver's platform
Date: Fri,  9 Apr 2010 12:24:19 +0200
Message-ID: <1270808662-7115-5-git-send-email-peppe.cavallaro@st.com>
References: <1270808662-7115-1-git-send-email-peppe.cavallaro@st.com>
 <1270808662-7115-2-git-send-email-peppe.cavallaro@st.com>
 <1270808662-7115-3-git-send-email-peppe.cavallaro@st.com>
 <1270808662-7115-4-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:44724 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757698Ab0DIKYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 06:24:51 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id A4F54138
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 10:24:49 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 695961953
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 10:24:49 +0000 (GMT)
In-Reply-To: <1270808662-7115-4-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new enh_desc is used for selecting the enhanced descriptors
structure. There are several scenarios; some chips (mac10/100
or gmac) want to use the enhanced descriptors; others want the normal
ones.
For example, on ST platforms: MAC10/100 uses the normal desc structure
and the GMAC uses the enhanced one.
It can be useful to get this information from the platform.
This could also be decided at run-time looking at the chip's ID number;
but it could happen that chips with the same ID want to use different
descriptor structure.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 include/linux/stmmac.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 32bfd1a..632ff7c 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -33,6 +33,7 @@ struct plat_stmmacenet_data {
 	int bus_id;
 	int pbl;
 	int has_gmac;
+	int enh_desc;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	void (*bus_setup)(unsigned long ioaddr);
 #ifdef CONFIG_STM_DRIVERS
-- 
1.6.0.4

