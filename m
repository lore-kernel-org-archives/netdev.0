From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 0/2] Mellanox 100G mlx5 minimum inline header mode
Date: Sun, 24 Jul 2016 16:12:38 +0300
Message-ID: <1469365960-27100-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:33760 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751482AbcGXNTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jul 2016 09:19:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This small series from Hadar adds the support for minimum inline header mode query
in mlx5e NIC driver.

Today on TX the driver copies to the HW descriptor only up to L2 header which is the default
required mode and sufficient for today's needs.

The header in the HW descriptor is used for HW loopback steering decision, without it packets 
will go directly to the wire with no questions asked.

For TX loopback steering according to L2/L3/L4 headers, ConnectX-4 requires to copy the
corresponding headers into the send queue(SQ) WQE HW descriptor so it can decide whether to loop it back
or to forward to wire.

For legacy E-Switch mode only L2 headers copy is required.
For advanced steering (E-Switch offloads) more header layers may be required to be copied,
the required mode will be advertised by FW to each VF and PF according to the corresponding
E-Switch configuration.

Changes V2:
 - Allocate query_nic_vport_context_out on the stack

Thanks,
Saeed.

Hadar Hen Zion (2):
  net/mlx5e: Check the minimum inline header mode before xmit
  net/mlx5e: Query minimum required header copy during xmit

 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  8 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 24 +++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 49 +++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/vport.c   | 12 ++++++
 include/linux/mlx5/device.h                       |  7 ++++
 include/linux/mlx5/mlx5_ifc.h                     | 10 +++--
 include/linux/mlx5/vport.h                        |  2 +
 7 files changed, 105 insertions(+), 7 deletions(-)

-- 
2.8.0
