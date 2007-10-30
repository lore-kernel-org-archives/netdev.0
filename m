From: Tom Southerland <toms@wonderland.us.com>
Subject: drivers/net/sunhme.c patch
Date: Mon, 29 Oct 2007 19:53:52 -0600
Message-ID: <47268EB0.5030703@wonderland.us.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-17-170-34.static.mesanetworks.net ([66.17.170.34]:33390 "EHLO
	wonderland.us.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752770AbXJ3CCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 22:02:12 -0400
Received: from [66.17.168.253] (pigpen.fullhilt.com [66.17.168.253])
	by wonderland.us.com (Postfix) with ESMTP id 957E474C14D
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 19:53:54 -0600 (MDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch provides a unique mac address for all interfaces
for the Sun QFE card (non-sparc).  It takes the base mac from
the first interface and increments the mac address for the
other interfaces.

It still preserves the 'macaddr' parameter so if desired, it
can still be used.

Before patching:

eth0      Link encap:Ethernet  HWaddr 00:03:BA:17:4C:BB
eth1      Link encap:Ethernet  HWaddr 00:03:BA:17:4C:BB
eth2      Link encap:Ethernet  HWaddr 00:03:BA:17:4C:BB
eth3      Link encap:Ethernet  HWaddr 00:03:BA:17:4C:BB

After patching:

eth0      Link encap:Ethernet  HWaddr 00:03:BA:17:4C:BB
eth1      Link encap:Ethernet  HWaddr 00:03:BA:17:4C:BC
eth2      Link encap:Ethernet  HWaddr 00:03:BA:17:4C:BD
eth3      Link encap:Ethernet  HWaddr 00:03:BA:17:4C:BE

Cheers,

Tom



--- linux-2.6.23.1/drivers/net/sunhme.c.orig    2007-10-29 07:58:25.000000000 -0600
+++ linux-2.6.23.1/drivers/net/sunhme.c 2007-10-29 08:53:03.000000000 -0600
@@ -3083,6 +3083,11 @@ static int __devinit happy_meal_pci_prob
                 }
  #else
                 get_hme_mac_nonsparc(pdev, &dev->dev_addr[0]);
+                if(macaddr[5] == 0){
+                 for (i = 0; i < 6; i++)
+                       macaddr[i] = dev->dev_addr[i];
+                 macaddr[5]++;
+                }
  #endif
         }


