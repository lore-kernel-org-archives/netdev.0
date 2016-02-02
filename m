From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net V1 0/3] mlx5 driver fixes for 4.5-rc2
Date: Tue,  2 Feb 2016 17:26:18 +0200
Message-ID: <1454426781-7128-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:58024 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932763AbcBBP0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 10:26:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Saeed fixed the case where VFs probed to the host shared the PF 
ndo_set_vf_yyy NDOs which is wrong, now along the lines of 
what you were asking.

We added here a patch from Matan and Alaa for addressing Linus comments on 
the mess w.r.t reserved field names in the driver/firmware auto-generated file. 

Once the patch hits linus tree, we'll ask Doug to rebase his tree on that 
rc so both net-next and rdma-next development for 4.6 will be done under 
the fixed robust form. 

Or.

changes from V0:
 - dropped Amir's patch, as the team considers some refactoring there
 - added const for the netdev ops struct, asked by Dave
 - modified the patch for treating correctly SRIOV NDOs
 - added patch to address the reserved field names in the IFC file

Matan Barak (1):
  net/mlx5: Use offset based reserved field names in the IFC header file

Saeed Mahameed (2):
  net/mlx5e: Remove select queue ndo initialization
  net/mlx5e: Use static constant netdevice ndos

 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   44 +-
 include/linux/mlx5/mlx5_ifc.h                     | 2956 ++++++++++-----------
 2 files changed, 1506 insertions(+), 1494 deletions(-)

-- 
2.3.7
