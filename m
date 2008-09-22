From: akpm@linux-foundation.org
Subject: [patch 13/21] e1000e: avoid duplicated output of device name in kernel warning
Date: Mon, 22 Sep 2008 14:52:22 -0700
Message-ID: <200809222152.m8MLqN7D031975@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	elendil@planet.nl, jeffrey.t.kirsher@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52713 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753963AbYIVV6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:58:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frans Pop <elendil@planet.nl>

With 2.6.27-rc3 I noticed the following messages in my boot log:

0000:01:00.0: 0000:01:00.0: Warning: detected DSPD enabled in EEPROM
0000:01:00.0: eth0: (PCI Express:2.5GB/s:Width x1) 00:16:76:04:ff:09

The second seems correct, but the first has a silly repetition of the
PCI device before the actual message. The message originates from
e1000_eeprom_checks in e1000e/netdev.c.

With this patch below the first message becomes

  e1000e 0000:01:00.0: Warning: detected DSPD enabled in EEPROM

which makes it similar to directly preceding messages.

Use dev_warn instead of e_warn in e1000_eeprom_checks() as the interface
name has not yet been assigned at that point.

[akpm@linux-foundation.org: coding-style fixes]
Signed-off-by: Frans Pop <elendil@planet.nl>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/e1000e/netdev.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff -puN drivers/net/e1000e/netdev.c~e1000e-avoid-duplicated-output-of-device-name-in-kernel-warning drivers/net/e1000e/netdev.c
--- a/drivers/net/e1000e/netdev.c~e1000e-avoid-duplicated-output-of-device-name-in-kernel-warning
+++ a/drivers/net/e1000e/netdev.c
@@ -4671,13 +4671,15 @@ static void e1000_eeprom_checks(struct e
 	ret_val = e1000_read_nvm(hw, NVM_INIT_CONTROL2_REG, 1, &buf);
 	if (!(le16_to_cpu(buf) & (1 << 0))) {
 		/* Deep Smart Power Down (DSPD) */
-		e_warn("Warning: detected DSPD enabled in EEPROM\n");
+		dev_warn(&adapter->pdev-dev,
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
 
_
