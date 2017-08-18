From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 00/12] nfp: add basic ethtool callbacks to representors
Date: Fri, 18 Aug 2017 15:48:10 -0700
Message-ID: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:34866 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751054AbdHRWtY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 18:49:24 -0400
Received: by mail-pg0-f43.google.com with SMTP id q6so1399560pgs.2
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 15:49:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This set extends the basic ethtool functionality to representor
netdevs.  I start with providing link state via ethtool and then
move on to functions such as driver information, statistics and
FW log dump.  The series contains a number of clean ups to the
ethtool stats code too, some of the logic is simplified by making 
better use of the nfp_port abstraction.  The stats we expose on 
representors are only the PCIe and MAC port statistics firmware 
maintains for us.


Jakub Kicinski (12):
  nfp: link basic ethtool ops to representors
  nfp: provide ethtool_drvinfo on representors
  nfp: allow retreiving management FW logs on representors
  nfp: don't report standard netdev statistics in ethtool
  nfp: add helper for printing ethtool strings
  nfp: split software and hardware vNIC statistics
  nfp: store pointer to MAC statistics in nfp_port
  nfp: report MAC statistics in ethtool
  nfp: add pointer to vNIC config memory to nfp_port structure
  nfp: add ethtool statistics for representors
  nfp: fix copy paste in names and messages regarding vNICs
  nfp: don't reuse pointers in ring dumping

 drivers/net/ethernet/netronome/nfp/flower/main.c   |   8 +-
 drivers/net/ethernet/netronome/nfp/nfp_app.c       |  20 +
 drivers/net/ethernet/netronome/nfp/nfp_app.h       |   2 +
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   2 -
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |  13 +-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   | 593 ++++++++++++++-------
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |   4 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c  |  59 +-
 drivers/net/ethernet/netronome/nfp/nfp_port.c      |   3 +
 drivers/net/ethernet/netronome/nfp/nfp_port.h      |  54 +-
 10 files changed, 497 insertions(+), 261 deletions(-)

-- 
2.11.0
