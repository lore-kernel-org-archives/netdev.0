From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/4] Endian fixes for SYSTEMPORT/SF2/MDIO
Date: Tue, 29 Aug 2017 13:35:14 -0700
Message-ID: <1504038918-49254-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34676 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751249AbdH2UlN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 16:41:13 -0400
Received: by mail-qk0-f194.google.com with SMTP id a77so3846804qkb.1
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 13:41:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

While trying an ARM BE kernel for kinks, the 3 drivers below started not
working and the reasons why became pretty obvious because the register space
remains LE (hardwired), except for Broadcom MIPS where it follows the CPU's
native endian (let's call that a feature).

Thanks!

Changes in v2:

- correctly set RSB_SWAP1 and RSB_SWAP0 for all combinations, now properly
  tested on SYSTEMPORT (BCM7445), SYSTEMPORT Lite (BCM7278) under both endian

Florian Fainelli (4):
  net: systemport: Use correct I/O accessors
  net: dsa: bcm_sf2: Use correct I/O accessors
  net: systemport: Set correct RSB endian bits based on host
  net: phy: mdio-bcm-unimac: Use correct I/O accessors

 drivers/net/dsa/bcm_sf2.h                  | 12 +++++------
 drivers/net/ethernet/broadcom/bcmsysport.c | 20 +++++++++++--------
 drivers/net/phy/mdio-bcm-unimac.c          | 32 ++++++++++++++++++++++++------
 3 files changed, 44 insertions(+), 20 deletions(-)

-- 
1.9.1
