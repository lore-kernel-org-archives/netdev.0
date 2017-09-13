From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net v2 0/3] nfp: wait more carefully for card init
Date: Wed, 13 Sep 2017 10:15:57 -0700
Message-ID: <20170913171600.31049-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:47892 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751413AbdIMRQu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 13:16:50 -0400
Received: by mail-pg0-f54.google.com with SMTP id d8so1542559pgt.4
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 10:16:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

The first patch is a small fix for flower offload, we need a whitelist
of supported matches, otherwise the unsupported ones will be ignored.

The second and the third patch are adding wait/polling to the probe path.
We had reports of driver failing probe because it couldn't find the 
control process (NSP) on the card.  Turns out the NSP will only announce
its existence after it's fully initialized.  Until now we assumed it 
will be reachable, just not processing commands (hence we wait for
a NOOP command to execute successfully).

v2:
 - fix a bad merge which resulted in a build warning and retest.

Jakub Kicinski (2):
  nfp: wait for board state before talking to the NSP
  nfp: wait for the NSP resource to appear on boot

Pieter Jansen van Vuuren (1):
  nfp: add whitelist of supported flow dissector

 .../net/ethernet/netronome/nfp/flower/offload.c    | 13 ++++++
 drivers/net/ethernet/netronome/nfp/nfp_main.c      | 47 ++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  | 23 -----------
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h   |  2 +
 .../ethernet/netronome/nfp/nfpcore/nfp_resource.c  | 45 +++++++++++++++++++++
 5 files changed, 107 insertions(+), 23 deletions(-)

-- 
2.14.1
