From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v2 0/6] Adding permanent config get/set to devlink
Date: Thu, 19 Oct 2017 15:17:04 -0400
Message-ID: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:42563 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751836AbdJSTR1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 15:17:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes since v1, based on the excellent feedback received:

* Implemented nested parameters correctly this time, I think.
* Submitting config get/set infrastructure separately from the
  parameters themselves, and then submitting just the first four
  parameters as separate patches.  Once this approach is
  accepted, I will add additional parameters, taking into
  account comments received on them.
* Changed devlink_nl_sing_param_get/set to use _single_.
* Tried to make clear that all params using this command are
  permanent / NVRAM settings, not transient.
* Split out the reorganization of bnxt driver to separate patch,
  submitted to net-next earlier today.
* One non-change: The devices this change affects don't typically
  have a separate 'asic' pci b/d/f versus per-port b/d/f; they
  just have (typically multiple) b/d/f entities for each function
  on the device.  So, doesn't seem to me like splitting these
  parameters into port vs.  device params works here.

Adds a devlink command for getting & setting permanent
(persistent / NVRAM) device configuration parameters, and
enumerates the parameters as nested devlink attributes.

bnxt driver patch makes use of these new devlink cmds.

Steve Lin (6):
  devlink: Add permanent config parameter get/set operations
  devlink: Adding SR-IOV enablement NVRAM config param
  devlink: Adding num VFs per PF NVRAM config param
  devlink: Adding max PF MSI-X vectors NVRAM config param
  devlink: Adding num MSI-X vectors per VF NVRAM config param
  bnxt: Add devlink support for config get/set

 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c | 245 +++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h |  17 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 100 +++++++++
 include/net/devlink.h                             |   3 +
 include/uapi/linux/devlink.h                      |  19 ++
 net/core/devlink.c                                | 234 +++++++++++++++++++++
 6 files changed, 612 insertions(+), 6 deletions(-)

-- 
2.7.4
