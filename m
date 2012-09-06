From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: [PATCH net 0/5] net/mlx4: Fixes to mlx4_core driver.
Date: Thu,  6 Sep 2012 11:50:47 +0300
Message-ID: <1346921452-2035-1-git-send-email-yevgenyp@mellanox.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:56621 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756720Ab2IFIvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 04:51:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

Add security check / enforcement for flow steering rules set for VMs:
Since VFs may be mapped to VMs which aren't trusted entities, flow
steering rules attached through the wrapper on behalf of VFs must be
checked to make sure that their L2 specification relate to MAC address
assigned to that VF, and add L2 specification if its missing.

Fixing bad handling of command failures, can lead to crash.

Fixing wrong promiscuous mode entries management.
---
Hadar Hen Zion (2):
  net/mlx4_core: Put Firmware flow steering structures in common header files
  net/mlx4_core: Add security check / enforcement for flow steering rules set for VMs
Aviad Yehezkel (2):
  net/mlx4_core: Looking for promiscuous entries on the correct port
  net/mlx4_core: Fixing error flow in case of QUERY_FW failure
Eugenia Emantayev (1):
  net/mlx4_core: Return the error value in case of command initialization failure

 drivers/net/ethernet/mellanox/mlx4/main.c             |   16 +-
 drivers/net/ethernet/mellanox/mlx4/mcg.c              |  106 ++--------------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h             |   76 +++++++++++
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |  116 ++++++++++++++++++
 include/linux/mlx4/device.h                           |   13 ++
 5 files changed, 229 insertions(+), 98 deletions(-)

-- 
1.7.8.2
