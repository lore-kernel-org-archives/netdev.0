From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net v5 0/3] net: libphy: Add phy specific functions to access mmd regs
Date: Tue, 29 Jul 2014 15:19:56 -0500
Message-ID: <1406665199-18174-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com, vbridger@altera.com
To: f.fainelli@gmail.com, rdunlap@infradead.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:60859 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261AbaG2UXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 16:23:36 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so195391pdj.22
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2014 13:23:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches addresses a problem found with the Micrel ksz9021 phy and
libphy, where the ksz9021 phy does not support mmd extended register access
per the IEEE specification as assumed by libphy. The first patch adds a
framework for phy specific support to specify their own function to access
extended phy registers, return a failure code if not supported, or to default
to libphy's IEEE defined method for accessing the mmd extended phy registers.

This issue was found by using the Synopsys EMAC and a Micrel ksz9021 phy on the
Altera Cyclone 5 SOC development kit. This patch was tested on the same system
in both positive and negative test cases.

---
V5: Revert name of mmd register access functions, check for phy specific
    driver override functions in mmd register access functions per
    Florian's comments to minimize source code changes
V4: Correct error when formatting V3 patch - erroneous text cut from code
V3: Correct formatting of function arguments, remove return statement from
    NULL functions, and add patch for PHY driver documentation per review
    comments.
V2: Split the original patch submission into seperate patches for the libphy
    framework required for the modification and for the Micrel Phy.

Vince Bridgers (3):
  net: libphy: Add phy specific function to access mmd phy registers
  net: libphy: Add stubs to hook IEEE MMD Register reads and writes
  Documentation: networking: phy.txt: Update text for indirect MMD
    access

 Documentation/networking/phy.txt |   18 ++++++++++-
 drivers/net/phy/micrel.c         |   22 ++++++++++++++
 drivers/net/phy/phy.c            |   61 ++++++++++++++++++++++++--------------
 include/linux/phy.h              |   18 +++++++++++
 4 files changed, 95 insertions(+), 24 deletions(-)

-- 
1.7.9.5
