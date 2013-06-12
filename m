From: Nikita Kiryanov <nikita@compulab.co.il>
Subject: Davicom DM9000A regression
Date: Wed, 12 Jun 2013 16:39:37 +0300
Message-ID: <51B87A19.4030708@compulab.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: josright123@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from softlayer.compulab.co.il ([50.23.254.55]:35960 "EHLO
	compulab.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751483Ab3FLONh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 10:13:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all.

I've encountered a connectivity problem with Davicom DM9000A chip.
The symptoms are the following message when booting via NFS:
dm9000 dm9000.0: eth0: link up, 100Mbps, full-duplex, lpa 0xCDE1

A bit of digging revealed the cause as this patch:
"DM9000B: driver initialization upgrade"
and specifically, the following line that was added by it:
dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET); /* PHY RESET */
(uncommenting this line solves the problem).
Adding a delay after the phy reset did not help.

I'll appreciate any insight someone might have on this issue.

-- 
Regards,
Nikita.
