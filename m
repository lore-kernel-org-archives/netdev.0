From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/2] mlx4 driver encapsulation/steering fixes
Date: Thu, 30 Oct 2014 15:59:26 +0200
Message-ID: <1414677568-28409-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:53772 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753422AbaJ3N7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 09:59:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The 1st patch fixes a bug in the TX path that supports offloading the 
TX checksum of (VXLAN) encapsulated TCP packets. It turns out that the 
bug is revealed only when the receiver runs in non-offloaded mode, so
we somehow missed it so far... please queue it for -stable >= 3.14 

The 2nd patch makes sure not to leak steering entry on error flow, 
please queue it to 3.17-stable 

thanks,

Or.

Or Gerlitz (2):
  net/mlx4_en: Don't attempt to TX offload the outer UDP checksum for VXLAN
  mlx4: Avoid leaking steering rules on flow creation error flow

 drivers/infiniband/hw/mlx4/main.c          |   10 ++++++++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    7 +++++--
 drivers/net/ethernet/mellanox/mlx4/mcg.c   |    4 ++++
 3 files changed, 17 insertions(+), 4 deletions(-)
