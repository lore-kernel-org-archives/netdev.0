From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net 0/7] net: qualcomm: rmnet: Fix some existing functionality
Date: Tue, 10 Oct 2017 18:20:22 -0600
Message-ID: <1507681229-27861-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43514 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756588AbdJKAVH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 20:21:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes some of the broken rmnet functionality from the initial
patchset. Bridge mode is re-written and made useable and the muxed_ep is
converted to hlist.

Patches 1-5 are cleanups in preparation for these changes.
Patch 6 does the hlist conversion.
Patch 7 has the implementation of the rmnet bridge mode.

Note that there will be a compilation error when merging net with net-next
due to the addition of the ext ack argument in
netdev_master_upper_dev_link / ndo_add_slave.

Subash Abhinov Kasiviswanathan (7):
  net: qualcomm: rmnet: Remove existing logic for bridge mode
  net: qualcomm: rmnet: Remove some unused defines
  net: qualcomm: rmnet: Move rmnet_mode to rmnet_port
  net: qualcomm: rmnet: Remove duplicate setting of rmnet private info
  net: qualcomm: rmnet: Remove duplicate setting of rmnet_devices
  net: qualcomm: rmnet: Convert the muxed endpoint to hlist
  net: qualcomm: rmnet: Implement bridge mode

 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c | 164 ++++++++++++++++-----
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h |  18 +--
 .../net/ethernet/qualcomm/rmnet/rmnet_handlers.c   | 131 ++++++----------
 .../net/ethernet/qualcomm/rmnet/rmnet_handlers.h   |   3 +-
 .../ethernet/qualcomm/rmnet/rmnet_map_command.c    |   4 +-
 .../net/ethernet/qualcomm/rmnet/rmnet_private.h    |   8 -
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c    |  36 ++---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h    |   7 +-
 8 files changed, 201 insertions(+), 170 deletions(-)

-- 
1.9.1
