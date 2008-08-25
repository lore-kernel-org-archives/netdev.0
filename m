From: Frans Pop <elendil@planet.nl>
Subject: [PATCH] e1000e: Avoid duplicated output of device name in kernel warning
Date: Mon, 25 Aug 2008 20:02:46 +0200
Message-ID: <200808252002.46585.elendil@planet.nl>
References: <200808181219.39921.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpo-eml06.kpnxchange.com ([213.75.38.155]:10723 "EHLO
	cpsmtpo-eml06.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753551AbYHYSCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 14:02:49 -0400
In-Reply-To: <200808181219.39921.elendil@planet.nl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 18 August 2008, Frans Pop wrote:
> With 2.6.27-rc3 I noticed the following messages in my boot log:
> 0000:01:00.0: 0000:01:00.0: Warning: detected DSPD enabled in EEPROM
> 0000:01:00.0: eth0: (PCI Express:2.5GB/s:Width x1) 00:16:76:04:ff:09
>
> The second seems correct, but the first has a silly repetition of the
> PCI device before the actual message. The message originates from
> e1000_eeprom_checks in e1000e/netdev.c.

With the patch below the first message becomes
  e1000e 0000:01:00.0: Warning: detected DSPD enabled in EEPROM
which makes it similar to directly preceding messages.

> Other question is why this is a "Warning"? Isn't "Deep Smart Power
> Down" a desirable feature to have?

I'm still wondering about this...
Same goes for the "warning" about ASPM.

---
From: Frans Pop <elendil@planet.nl>

Use dev_warn instead of e_warn in e1000_eeprom_checks() as the
interface name has not yet been assigned at that point.
    
Signed-off-by: Frans Pop <elendil@planet.nl>

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index d266510..d02a659 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4335,13 +4335,15 @@ static void e1000_eeprom_checks(struct 
e1000_adapter *adapter)
 	ret_val = e1000_read_nvm(hw, NVM_INIT_CONTROL2_REG, 1, &buf);
 	if (!(le16_to_cpu(buf) & (1 << 0))) {
 		/* Deep Smart Power Down (DSPD) */
-		e_warn("Warning: detected DSPD enabled in EEPROM\n");
+		dev_warn(&adapter->pdev->dev,
+			 "Warning: detected DSPD enabled in EEPROM\n");
 	}
 
 	ret_val = e1000_read_nvm(hw, NVM_INIT_3GIO_3, 1, &buf);
 	if (le16_to_cpu(buf) & (3 << 2)) {
 		/* ASPM enable */
-		e_warn("Warning: detected ASPM enabled in EEPROM\n");
+		dev_warn(&adapter->pdev->dev,
+			 "Warning: detected ASPM enabled in EEPROM\n");
 	}
 }
 
