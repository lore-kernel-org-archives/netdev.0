From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: [PATCH 0/2] at803x: don't power-down SGMII link
Date: Mon, 24 Oct 2016 12:40:52 +0200
Message-ID: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
Cc: timur@codeaurora.org, andrew@lunn.ch, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:35865 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753891AbcJXKlD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 06:41:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a device where the ar8031 operates in SGMII mode, we
observed that after a suspend-resume cycle in very rare
cases the copper side autonegotiation secceeds but the
SGMII side fails to come up.

As a work-around, a patch was provided that on suspend and
resume powers the SGMII link down and up along with the
copper side. This fixed the observed failure, but
introduced a regression Timur Tabi observed: once the SGMII
is powered down, the PHY is inaccessible by the CPU and
with that e.g. can't be re-initialized after suspend.

Since the original issue could not be reproduced by others,
this series provides an alternative handling:
* the first patch reverts the prvious fix that powers down
  SGMII
* the second patch adds double-checking for the observed
  failure condition

Zefir Kurtisi (2):
  Revert "at803x: fix suspend/resume for SGMII link"
  at803x: double check SGMII side autoneg

 drivers/net/phy/at803x.c | 65 +++++++++++++++++++++++++++++-------------------
 1 file changed, 39 insertions(+), 26 deletions(-)

-- 
2.7.4
