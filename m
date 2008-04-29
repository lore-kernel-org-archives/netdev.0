From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Error handling corner case found during audits
Date: Tue, 29 Apr 2008 14:31:19 +0100
Message-ID: <20080429143119.4ef252d6@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:49597 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756464AbYD2Nip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 09:38:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not sure what should happen here.


diff -u --new-file --recursive --exclude-from /usr/src/exclude linux.vanilla-2.6.25-mm1/drivers/net/e1000e/ethtool.c linux-2.6.25-mm1/drivers/net/e1000e/ethtool.c
--- linux.vanilla-2.6.25-mm1/drivers/net/e1000e/ethtool.c	2008-04-28 11:36:49.000000000 +0100
+++ linux-2.6.25-mm1/drivers/net/e1000e/ethtool.c	2008-04-18 16:42:41.000000000 +0100
@@ -494,6 +494,8 @@
 		for (i = 0; i < last_word - first_word + 1; i++) {
 			ret_val = e1000_read_nvm(hw, first_word + i, 1,
 						      &eeprom_buff[i]);
+			/* ERROR: This path leaves eeprom_buf containing
+			   old kernel bytes we then byteswap/return */
 			if (ret_val)
 				break;
 		}
