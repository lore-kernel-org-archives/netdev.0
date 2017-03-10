From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/10] mlxsw: Preparations for VRF offload
Date: Fri, 10 Mar 2017 08:53:33 +0100
Message-ID: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35245 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750936AbdCJHxq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 02:53:46 -0500
Received: by mail-wr0-f196.google.com with SMTP id u108so10564630wrb.2
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 23:53:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

This patchset aims to prepare the mlxsw driver for VRF offload. The
follow-up patchsets that introduce VRF support can be found here:
https://github.com/idosch/linux/tree/idosch-next

The first four patches are mainly concerned with the netdevice
notification block. There are no functional changes, but merely
restructuring to more easily integrate VRF enslavement.

Patches 5-10 remove various assumptions throughout the code about a
single virtual router (VR) and also restructure the internal data
structures to more accurately represent the device's operation.

Ido Schimmel (10):
  mlxsw: spectrum: Sanitize bridge's upper devices
  mlxsw: spectrum: Don't assume upper device's type
  mlxsw: spectrum: Associate PVID vPort with appropriate netdev
  mlxsw: spectrum: Destroy RIFs based on last removed address
  mlxsw: spectrum_router: Allow more route types to be programmed
  mlxsw: spectrum_router: Place RIF related code with router code
  mlxsw: spectrum_router: Simplify LPM tree allocation
  mlxsw: spectrum_router: Refactor virtual router handling
  mlxsw: spectrum_router: Explicitly Associate RIFs with VRs
  mlxsw: spectrum_router: Make abort mechanism VR-aware

 drivers/net/ethernet/mellanox/mlxsw/reg.h          |    4 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  598 +---------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   52 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 1159 +++++++++++++++-----
 4 files changed, 956 insertions(+), 857 deletions(-)

-- 
2.7.4
