From: Teresa Remmet <t.remmet@phytec.de>
Subject: net: ti: cpsw-phy-sel: RGMII is not working on AM335x
Date: Wed, 11 Jan 2017 09:14:23 +0100
Message-ID: <1484122463.3777.1.camel@phytec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org
To: Alexandru Gagniuc <alex.g@adaptrum.com>,
        "David S. Miller" <davem@davemloft.net>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.x-arc.de ([217.6.246.34]:44576 "EHLO root.phytec.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932539AbdAKIO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 03:14:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I met a issue with the gmii_sel register on the AM335x when using
RGMII. The patch,

commit 74685b08fbb26ff5b8448fabe0941a53269dd33e
Author: Alex <alex.g@adaptrum.com>
Date:   Tue Dec 6 10:56:51 2016 -0800

    drivers: net: cpsw-phy-sel: Clear RGMII_IDMODE on "rgmii" links
    
    Support for setting the RGMII_IDMODE bit was added in the commit
    referenced below. However, that commit did not add the symmetrical
    clearing of the bit by way of setting it in "mask". Add it here.
    
    Note that the documentation marks clearing this bit as "reserved",
    however, according to TI, support for delaying the clock does exist in
    the MAC, although it is not officially supported.
    We tested this on a board with an RGMII to RGMII link that will not
    work unless this bit is cleared.
    
    Fixes: 0fb26c3063ea ("drivers: net: cpsw-phy-sel: add support to configure rgmii int
    Signed-off-by: Alexandru Gagniuc <alex.g@adaptrum.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


is suppose to fix the RGMII mode with setting the RGMII0/1_ID_MODE
bit to 0: "Reserved". I use RMII1 and RGMII2 on our custom 
AM335x board. The RMII1 is still working with the patch but
I do not get any data transfered on the RGMII2. When I revert
the patch, everything works again.
I tested this on 4.10-rc3.

The AM335x TRM Rev. O notes on Chapter 14.3.6.4:
"The RGMII0/1_ID_MODE bit value in the GMII_SEL register should
only be set to 1 for 'no internal delay'.
The device does not support internal delay mode for RGMII."

So I wonder what is correct now? As for me the patch makes RGMII unusable.
Has anyone an explanation?

Regards,
Teresa
