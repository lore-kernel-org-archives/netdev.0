From: Gal Pressman <galp@mellanox.com>
Subject: [RFC PATCH net-next 0/3] ethtool: Add link down reason reporting
Date: Wed, 21 Jun 2017 16:04:43 +0300
Message-ID: <1498050286-17141-1-git-send-email-galp@mellanox.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com,
        Gal Pressman <galp@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34594 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751004AbdFUNFU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 09:05:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

Currently, drivers can only tell whether the link is up/down through
ETHTOOL_GLINK callback, but no additional information is given in case
of link down/failure.

This series provides an infrastructure to ethtool that allows 
netdevice drivers to hint the user with the reason why the link is down,
in order to ease the debug process.

In addition two more mlx5 patches to demonstrate the usage.

Reasons are separated to two types, generic and vendor specific.
Drivers can reply with a generic reason using the predefined enums 
(and the ones that will be added in the future), which will be
translated to strings by the userspace ethtool.
In case of a vendor specific reason, drivers can reply with
ETHTOOL_VENDOR_SPECIFIC reason, in this case the vendor_reason field
should be filled with a vendor specific status code which will be parsed
by the vendor specific userspace parser if one is available.

This kind of information can save system administrators precious time,
which will not be wasted trying to understand why the link won't go up.
    
For example, when the cable is unplugged:
    $ ethtool ethXX
    ...
    Link detected: no (Cable unplugged)

Thanks,
Gal.

Gal Pressman (3):
  ethtool: Add link down reason callback
  net/mlx5: Add PDDR register infrastructure
  net/mlx5e: Expose link down reason to ethtool

 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 107 +++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  33 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  39 ++++++++
 include/linux/ethtool.h                            |   2 +
 include/linux/mlx5/device.h                        |   3 +
 include/linux/mlx5/driver.h                        |   1 +
 include/linux/mlx5/mlx5_ifc.h                      |  51 ++++++++++
 include/uapi/linux/ethtool.h                       |  33 +++++++
 net/core/ethtool.c                                 |  24 +++++
 9 files changed, 293 insertions(+)

-- 
2.7.4
