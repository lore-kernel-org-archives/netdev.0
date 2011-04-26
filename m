From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [PATCH] igb: restore EEPROM 16kB access limit
Date: Tue, 26 Apr 2011 08:10:08 -0700
Message-ID: <EDC0E76513226749BFBC9C3FB031318F016AF3900B@orsmsx508.amr.corp.intel.com>
References: <1302269695-27188-1-git-send-email-sassmann@kpanic.de>
 <EDC0E76513226749BFBC9C3FB031318F0137E85A8E@orsmsx508.amr.corp.intel.com>
 <4D9F6A44.7060809@kpanic.de>
 <EDC0E76513226749BFBC9C3FB031318F0137E85E47@orsmsx508.amr.corp.intel.com>
 <4DB6DF9B.90706@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Andy Gospodarek <gospo@redhat.com>
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59559 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756753Ab1DZPKa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 11:10:30 -0400
In-Reply-To: <4DB6DF9B.90706@kpanic.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Stefan Assmann [mailto:sassmann@kpanic.de]
>Sent: Tuesday, April 26, 2011 8:07 AM
>To: Wyborny, Carolyn
>Cc: netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net; Kirsher,
>Jeffrey T; Pieper, Jeffrey E; Ronciak, John; Andy Gospodarek
>Subject: Re: [PATCH] igb: restore EEPROM 16kB access limit
>
>New patch against net-next-2.6.
>
>  Stefan
>
>From 67ce9e09e10f05054a26560306aa484ae3acc03f Mon Sep 17 00:00:00 2001
>From: Stefan Assmann <sassmann@kpanic.de>
>Date: Mon, 18 Apr 2011 15:22:19 +0200
>Subject: [PATCH] igb: default to 32kB for EEPROMs reporting invalid size
>
>The check that gracefully handled invalid EEPROM sizes was removed by
>commit 4322e561a93ec7ee034b603a6c610e7be90d4e8a. Without this check the
>EEPROM validation fails if the size is invalid and the NIC is not usable
>by the OS. Observed with a 8086:10c9 NIC.
>
>igb 0000:03:00.0: 0 vfs allocated
>igb 0000:03:00.0: The NVM Checksum Is Not Valid
>ACPI: PCI interrupt for device 0000:03:00.0 disabled
>igb: probe of 0000:03:00.0 failed with error -5
>
>Re-introducing the check with an additional dev_err() to report the
>problem.
>
>Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
>---
> drivers/net/igb/e1000_82575.c |   10 ++++++++++
> 1 files changed, 10 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/igb/e1000_82575.c
>b/drivers/net/igb/e1000_82575.c
>index 0cd41c4..f3bdf29 100644
>--- a/drivers/net/igb/e1000_82575.c
>+++ b/drivers/net/igb/e1000_82575.c
>@@ -31,9 +31,11 @@
>
> #include <linux/types.h>
> #include <linux/if_ether.h>
>+#include <linux/pci.h>
>
> #include "e1000_mac.h"
> #include "e1000_82575.h"
>+#include "igb.h"
>
> static s32  igb_get_invariants_82575(struct e1000_hw *);
> static s32  igb_acquire_phy_82575(struct e1000_hw *);
>@@ -113,6 +115,7 @@ static s32 igb_get_invariants_82575(struct e1000_hw
>*hw)
> 	struct e1000_nvm_info *nvm = &hw->nvm;
> 	struct e1000_mac_info *mac = &hw->mac;
> 	struct e1000_dev_spec_82575 * dev_spec = &hw->dev_spec._82575;
>+	struct igb_adapter *adapter = hw->back;
> 	u32 eecd;
> 	s32 ret_val;
> 	u16 size;
>@@ -244,6 +247,13 @@ static s32 igb_get_invariants_82575(struct e1000_hw
>*hw)
> 	 */
> 	size += NVM_WORD_SIZE_BASE_SHIFT;
>
>+	/* gracefully handle NICs reporting an invalid EEPROM size */
>+	if (size > 15) {
>+		dev_err(&adapter->pdev->dev,
>+		        "NVM size is not valid, defaulting to 32kB\n");
>+		size = 15;
>+	}
>+
> 	nvm->word_size = 1 << size;
> 	if (nvm->word_size == (1 << 15))
> 		nvm->page_size = 128;
>--
>1.7.4

I have already submitted a patch to fix this in our internal process, but our maintainer has been ill.  It should be out shortly.  I thought you agreed with Alex to let us submit the patch as this code in our Shared Code and we need to retain the copyright.

I will get with Jeff to get it out as soon as possible.

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation



