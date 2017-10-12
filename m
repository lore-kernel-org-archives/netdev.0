From: Steve Lin <steven.lin1@broadcom.com>
Subject: [RFC 0/3] Adding config get/set to devlink
Date: Thu, 12 Oct 2017 09:34:19 -0400
Message-ID: <1507815262-33294-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linux-pci@vger.kernel.org, linville@tuxdriver.com,
        gospo@broadcom.com, steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:50303 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757244AbdJLNey (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 09:34:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds a devlink command for getting & setting device configuration
parameters, and enumerates a bunch of those parameters as devlink
attributes.  Also introduces an attribute that can be set by a
driver to indicate that the config change doesn't take effect
until the next restart (as in the case of the bnxt driver changes
in this patchset, for which all the configuration changes affect NVM
only, and aren't loaded until the next restart.)

bnxt driver patches make use of these new devlink cmds/attributes.

Steve Lin (3):
  devlink: Add config parameter get/set operations
  bnxt: Move generic devlink code to new file
  bnxt: Add devlink support for config get/set

 drivers/net/ethernet/broadcom/bnxt/Makefile       |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |   1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c | 403 ++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h |  56 +++
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 100 ++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c     |  97 +-----
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h     |  35 +-
 include/net/devlink.h                             |   4 +
 include/uapi/linux/devlink.h                      | 108 ++++++
 net/core/devlink.c                                | 207 +++++++++++
 10 files changed, 882 insertions(+), 131 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h

-- 
2.7.4
