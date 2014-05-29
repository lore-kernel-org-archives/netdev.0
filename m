From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net V2 0/2] libphy: Add phy specific function to access mmd
Date: Thu, 29 May 2014 11:28:31 -0500
Message-ID: <1401380913-4207-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com
To: f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:49914 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757774AbaE2Qcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 12:32:48 -0400
Received: by mail-pa0-f48.google.com with SMTP id rd3so628637pab.7
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 09:32:47 -0700 (PDT)
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

Please consider including this patch if you find these modifications
acceptable.

---
V2: Split the original patch submission into seperate patches for the libphy
    framework required for the modification and for the Micrel Phy.

Vince Bridgers (2):
  libphy: Add phy specific function to access mmd phy registers
  libphy: Add stubs to hook IEEE MMD Register reads and writes

 drivers/net/phy/micrel.c     |   23 ++++++++++++++++++++
 drivers/net/phy/phy.c        |   49 ++++++++++++++++++++++--------------------
 drivers/net/phy/phy_device.c |    6 ++++++
 include/linux/phy.h          |   10 +++++++++
 4 files changed, 65 insertions(+), 23 deletions(-)

-- 
1.7.9.5
