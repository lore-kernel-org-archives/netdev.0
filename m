From: Mike McCormack <mikem@ring3k.org>
Subject: Re: Regression: Wake on LAN doesn't work in sky2 with 2.6.33-rc4-git2
Date: Mon, 18 Jan 2010 20:59:40 +0900
Message-ID: <4B544D2C.8040400@ring3k.org>
References: <20100115091053.GA5477@mac.home> <201001152323.37718.rjw@sisk.pl> <20100117231932.GA5504@mac.home> <201001180136.45823.rjw@sisk.pl> <20100118083757.GA2619@mac.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:63474 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754299Ab0ARMEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 07:04:08 -0500
In-Reply-To: <20100118083757.GA2619@mac.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tino Keitel wrote:
> Hi,
> 
> reverting this commit fixes WoL for me:
> 
> commit 166a0fd4c788ec7f10ca8194ec6d526afa12db75

Hi Tino,

Does this fix WoL also?  Compile tested only...

thanks,

Mike


Subject: [PATCH] sky2: Disable writes to PCI space before suspend

Tino Keitel found that reverting 166a0fd4c fixes WoL for him.
This suggests that PCI config should not be writable when suspended.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 4c06020..b54edec 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4789,6 +4789,9 @@ static int sky2_suspend(struct pci_dev *pdev, pm_message_t state)
 	sky2_power_aux(hw);
 	rtnl_unlock();
 
+	/* disable writes to PCI config again */
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
+
 	pci_save_state(pdev);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), wol);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-- 1.5.6.5 
