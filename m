From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/7] net: dsa: bcm_sf2: Add support for IPv6 CFP rules
Date: Fri, 20 Oct 2017 14:39:42 -0700
Message-ID: <20171020213949.16485-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:56945 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752498AbdJTVjy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 17:39:54 -0400
Received: by mail-qk0-f193.google.com with SMTP id l194so15965249qke.13
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 14:39:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds support for matching IPv6 addresses to the existing CFP
support code. Because IPv6 addresses are four times bigger than IPv4, we can
fit them anymore in a single slice, so we need to chain two in order to have
a complete match. This makes us require a second bitmap tracking unique rules
so we don't over populate the TCAM.

Finally, because the code had to be re-organized, it became a lot easier to
support arbitrary prefix/mask lengths, so the last two patches do just that.

Florian Fainelli (7):
  net: dsa: bcm_sf2: Use existing shift/masks
  net: dsa: bcm_sf2: Move IPv4 CFP processing to specific functions
  net: dsa: bcm_sf2: Make UDF slices more configurable
  net: dsa: bcm_sf2: Simplify bcm_sf2_cfp_rule_get_all()
  net: dsa: bcm_sf2: Add support for IPv6 CFP rules
  net: dsa: bcm_sf2: Allow matching arbitrary IPv4 mask lengths
  net: dsa: bcm_sf2: Allow matching arbitrary IPv6 masks/lengths

 drivers/net/dsa/bcm_sf2.c      |    1 +
 drivers/net/dsa/bcm_sf2.h      |    1 +
 drivers/net/dsa/bcm_sf2_cfp.c  | 1196 ++++++++++++++++++++++++++++++----------
 drivers/net/dsa/bcm_sf2_regs.h |   15 +-
 4 files changed, 935 insertions(+), 278 deletions(-)

-- 
2.14.1
