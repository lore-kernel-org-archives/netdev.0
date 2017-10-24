From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 0/7] Add support for resource abstraction
Date: Tue, 24 Oct 2017 11:22:38 +0200
Message-ID: <20171024092245.1386-1-jiri@resnulli.us>
Cc: davem@davemloft.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com, ast@kernel.org,
        daniel@iogearbox.net, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com, linville@tuxdriver.com,
        gospo@broadcom.com, steven.lin1@broadcom.com, yuvalm@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:47572 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932274AbdJXJWr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:22:47 -0400
Received: by mail-wm0-f66.google.com with SMTP id t69so14351923wmt.2
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 02:22:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Arkadi says:

Many of the ASIC's internal resources are limited and are shared between
several hardware procedures. For example, unified hash-based memory can
be used for many lookup purposes, like FDB and LPM. In many cases the user
can provide a partitioning scheme for such a resource in order to perform
fine tuning for his application. In many cases after setting the partitioning
of the resource driver reload is needed. This patchset add support for hot
reset of the driver.

The proposed interface will provide the user the ability to understand the
limitations of the hardware, and receive notification regarding its occupancy.
Furthermore, monitoring the resource occupancy can be done in real-time and
can be useful in many cases.

Arkadi Sharshevsky (7):
  devlink: Add support for resource abstraction
  devlink: Add per devlink instance lock
  devlink: Add support for reload
  mlxsw: pci: Add support for performing bus reset
  mlxsw: Register KVD resources with devlink
  mlxsw: pci: Add support for getting resource through devlink
  mlxsw: core: Add support for reload

 drivers/net/ethernet/mellanox/mlxsw/core.c     |  79 ++++-
 drivers/net/ethernet/mellanox/mlxsw/core.h     |  15 +-
 drivers/net/ethernet/mellanox/mlxsw/i2c.c      |   4 +-
 drivers/net/ethernet/mellanox/mlxsw/pci.c      | 100 ++++---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 148 +++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  12 +
 include/net/devlink.h                          |  76 +++++
 include/uapi/linux/devlink.h                   |   9 +
 net/core/devlink.c                             | 385 ++++++++++++++++++++++++-
 9 files changed, 752 insertions(+), 76 deletions(-)

-- 
2.9.5
