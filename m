From: Kristoffer Glembo <kristoffer@gaisler.com>
Subject: phy_connect_direct problem
Date: Tue, 27 Oct 2009 11:28:58 +0100
Message-ID: <4AE6CB6A.5050600@gaisler.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail168c2.megamailservers.com ([69.49.111.68]:58474 "EHLO
	mail168c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753428AbZJ0LJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 07:09:23 -0400
Received: from [192.168.0.35] (c-10a5e155.260-1-64736c10.cust.bredbandsbolaget.se [85.225.165.16])
	(authenticated bits=0)
	by mail168c2.megamailservers.com (8.13.6/8.13.1) with ESMTP id n9RAVY3O007510
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2009 06:31:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm in the process of converting an ethernet driver to using the PHY 
layer, but ran into a problem where my adjust_state handler was never 
called and the link did not go up ...

I use phy_connect to connect the PHY device with my ethernet driver. In 
phy_connect_direct I found the following code: 	

phy_prepare_link(phydev, handler);
phy_start_machine(phydev, NULL);

So first the adjust_state is set to handler by phy_prepare_link and then 
it is overwritten with the NULL parameter passed to phy_start_machine.

Maybe I'm abusing the PHY layer somehow since there are plenty of other 
drivers using this interface. However the patch below solved the issue 
for me.

Best regards,
Kristoffer Glembo


---
  drivers/net/phy/phy_device.c |    3 +--
  1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index b10fedd..d27ca80 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -311,8 +311,7 @@ int phy_connect_direct(struct net_device *dev, 
struct phy_device *phydev,
  	if (rc)
  		return rc;

-	phy_prepare_link(phydev, handler);
-	phy_start_machine(phydev, NULL);
+	phy_start_machine(phydev, handler);
  	if (phydev->irq > 0)
  		phy_start_interrupts(phydev);

-- 
1.5.2.2
