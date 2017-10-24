From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v3 00/10] Adding permanent config get/set to devlink
Date: Tue, 24 Oct 2017 16:12:32 -0400
Message-ID: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com,
        steven.lin1@broadcom.com, yuvalm@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:58352 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751536AbdJXUNq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 16:13:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes since v2:

* Removed references to "NVRAM" in comments / commits.
* Add parameter descriptions to header file.
* Split bnxt patch into infrastructure, then one patch
  for each new parameter.
* Cleaned up goofs (unused parameters leftover from v1)
* Used enum rather than u32 in prototype for perm_config_get()
  and _set().
* Defined DEVLINK_ATTR_PERM_CONFIG_TYPE so future parameters
  can use arbitrary types (not just U32 and smaller).
* Reverse Christmas tree local variable definitions.
* No longer return original/previous value of parameter in
  response to set.
* Check parameter within enum limits before using it as array
  index.

I have NOT implemented the following suggested changes:

* Have driver report what parameters and parameter options it
  supports.  Could be done in future patch by defining new
  devlink op.
* Support parameters spread across multi-part netlink messages.
  See discussion on list - this doesn't seem necessary even
  for devices with large number of parameters.
* Support specifying per-VF config, if the VFs don't have
  pci b/d/f associated with them.  See discussion on list;
  if/when this support is required, could add
  DEVLINK_ATTR_PERM_CONFIG_VF_INDEX to describe, without
  breaking UAPI.
* Rolling back previously set parameters in a collection of
  sets, when one fails.  Instead, we report back to user
  which sets were successful, so they know which were set
  and which weren't, and can decide how to proceed.

--

Adds a devlink command for getting & setting permanent /
persistent device configuration parameters, and enumerates
the parameters as nested devlink attributes.

bnxt driver patches makes use of these new devlink cmds.

Steve Lin (10):
  devlink: Add permanent config parameter get/set operations
  devlink: Adding SR-IOV enablement perm config param
  devlink: Adding num VFs per PF permanent config param
  devlink: Adding max PF MSI-X vectors perm config param
  devlink: Adding num MSI-X vectors per VF perm config param
  bnxt: Add devlink support for config get/set
  bnxt: Adding SR-IOV enablement permanent cfg param
  bnxt: Adding num VFs per PF perm config param
  bnxt: Adding max PF MSI-X vectors perm config param
  bnxt: Adding num MSI-X vectors per VF perm config param

 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c | 281 +++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h |  17 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 100 ++++++++
 include/net/devlink.h                             |   6 +
 include/uapi/linux/devlink.h                      |  33 +++
 net/core/devlink.c                                | 299 ++++++++++++++++++++++
 6 files changed, 730 insertions(+), 6 deletions(-)

-- 
2.7.4
