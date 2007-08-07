From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFT] sky2: turn on pci power
Date: Tue, 7 Aug 2007 15:12:44 -0400
Message-ID: <20070807151244.26471f59@oldman>
References: <20070724082205.GA19480@paradigm.rfc822.org>
	<20070724095008.0eb154fe@oldman.hamilton.local>
	<20070724094042.GA6414@paradigm.rfc822.org>
	<6bffcb0e0707241630p3599ad99sfd778097b307e78c@mail.gmail.com>
	<20070725072202.GA4905@paradigm.rfc822.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	netdev@vger.kernel.org
To: Florian Lohoff <flo@rfc822.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40215 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751195AbXHGTMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 15:12:37 -0400
In-Reply-To: <20070725072202.GA4905@paradigm.rfc822.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This setup step got dropped in 2.6.23, Yukon-EX configuration, maybe
this fixes your problem?

--- a/drivers/net/sky2.c	2007-08-06 04:39:36.000000000 -0400
+++ b/drivers/net/sky2.c	2007-08-07 14:50:25.000000000 -0400
@@ -222,6 +222,8 @@ static void sky2_power_on(struct sky2_hw
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_EX) {
 		u32 reg;
 
+		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
+
 		reg = sky2_pci_read32(hw, PCI_DEV_REG4);
 		/* set all bits to 0 except bits 15..12 and 8 */
 		reg &= P_ASPM_CONTROL_MSK;
