From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net v3 0/3] libphy: Add phy specific function to access mmd
Date: Sun, 22 Jun 2014 19:21:47 -0500
Message-ID: <1403482910-20821-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com
To: f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:55316 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbaFWAZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2014 20:25:48 -0400
Received: by mail-ig0-f180.google.com with SMTP id h18so2361898igc.7
        for <netdev@vger.kernel.org>; Sun, 22 Jun 2014 17:25:47 -0700 (PDT)
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
V3: Correct formatting of function arguments, remove return statement from
    NULL functions, and add patch for PHY driver documentation per review
    comments.
V2: Split the original patch submission into seperate patches for the libphy
    framework required for the modification and for the Micrel Phy.

Vince Bridgers (3):
  libphy: Add phy specific function to access mmd phy registers
  libphy: Add stubs to hook IEEE MMD Register reads and writes
  Documentation: networking: phy.txt: Update text for indirect MMD
    access

 Documentation/networking/phy.txt |   18 ++++++++++-
 drivers/net/phy/micrel.c         |   23 +++++++++++++-
 drivers/net/phy/phy.c            |   64 ++++++++++++++++++++------------------
 drivers/net/phy/phy_device.c     |    6 ++++
 include/linux/phy.h              |   10 ++++++
 5 files changed, 89 insertions(+), 32 deletions(-)

-- 
1.7.9.5
