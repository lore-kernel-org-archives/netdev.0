From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V2 0/3] mlx5 driver fixes for 4.5-rc2
Date: Tue,  9 Feb 2016 14:57:41 +0200
Message-ID: <1455022664-15202-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34060 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751653AbcBIM6P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2016 07:58:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We added here a patch from Matan and Alaa for addressing Linus comments on
the mess w.r.t reserved field names in the driver/firmware auto-generated file.

Once the patch hits linus tree, we'll ask Doug to rebase his tree on that
rc so both net-next and rdma-next development for 4.6 will be done under
the fixed robust form.

Also provided two patches that addresses the dynamic ndo initialization
issue of mlx5e netdevice.

Or and Saeed.

changes from V1: (Only first patch was changed)
In this V we fixed the issues addressed in Or's previous e-mail.
	1. Offsets took into account two dimensional u8 arrays
	2. Offsets took into account nesting unions and structs
	3. Offsets for unions
	4. Offsets for any reserved field

Matan Barak (1):
  net/mlx5: Use offset based reserved field names in the IFC header
    file

Saeed Mahameed (2):
  net/mlx5e: Remove select queue ndo initialization
  net/mlx5e: Use static constant netdevice ndos

 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   44 +-
 include/linux/mlx5/mlx5_ifc.h                     | 2968 ++++++++++----------
 2 files changed, 1512 insertions(+), 1500 deletions(-)
