From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/8] batch of mlx4 driver fixes
Date: Mon, 14 May 2012 23:04:05 +0300
Message-ID: <1337025853-26685-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:43608 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757449Ab2ENUEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 16:04:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This is a batch of relatively small fixes for the mlx4_core driver, except for 
one cleanup patch from myself, all the patches are from Jack Morgenstein, who 
leads our SRIOV development efforts and do relate to the SRIOV functionality.
With Yevgeny being mostly out this week and as both of us run the internal 
reviews for upstream patches, he delegated this submission to be carried 
out by me, hope this is fine by you.

Or.

Jack Morgenstein (7):
  net/mlx4_core: Fix init_port mask state for slaves
  net/mlx4_core: Change SYNC_TPT to be native (not wrapped)
  net/mlx4_core: Remove unused *_str functions from the resource tracker
  net/mlx4_core: Do not reset module-parameter num_vfs when fail to enable sriov
  net/mlx4_core: Fix potential kernel Oops in res tracker during Dom0 driver unload
  net/mlx4_core: Add XRC domains and counters to resource tracker
  net/mlx4_core: Fixed error flow in rem_slave_eqs

Or Gerlitz (1):
  net/mlx4: Address build warnings on set but not used variables

 drivers/net/ethernet/mellanox/mlx4/cmd.c           |    7 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |    3 +-
 drivers/net/ethernet/mellanox/mlx4/main.c          |   47 +++-
 drivers/net/ethernet/mellanox/mlx4/mcg.c           |    2 -
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   12 +-
 drivers/net/ethernet/mellanox/mlx4/mr.c            |    5 +-
 drivers/net/ethernet/mellanox/mlx4/pd.c            |   39 +++-
 drivers/net/ethernet/mellanox/mlx4/port.c          |    3 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  269 ++++++++++++++++----
 9 files changed, 316 insertions(+), 71 deletions(-)

Cc: Jack Morgenstein <jackm@dev.mellanox.co.il>
