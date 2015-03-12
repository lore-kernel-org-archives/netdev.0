From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 0/3] Add max rate TXQ attribute
Date: Thu, 12 Mar 2015 10:53:22 +0200
Message-ID: <1426150405-7904-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:47988 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751467AbbCLIx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 04:53:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ability to set a max-rate limitation for TX queues.
The attribute name is maxrate and the units are Mbs, to make
it similar to the existing max-rate limitation knobs (ETS and 
SRIOV ndo calls).

changes from V0:
  - addressed feedback from Sergei (thanks).

John, you suggested to add another way (e.g through netlink) to 
program the TXQ maxrate limit, I am OK to add that after we bake 
it a little further (see my response on V0). I would suggest to make 
progress on the current series which includes the basic ndo, TXQ sysfs 
entry & driver implementation, and add more injection points on top 
of it, once accepted, makes sense?

Or.


John Fastabend (1):
  net: Add max rate tx queue attribute

Or Gerlitz (2):
  net/mlx4_core: Add basic support for QP max-rate limiting
  net/mlx4_en: Add tx queue maxrate support

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   29 ++++++++
 drivers/net/ethernet/mellanox/mlx4/fw.c            |   33 +++++++++-
 drivers/net/ethernet/mellanox/mlx4/fw.h            |    1 +
 drivers/net/ethernet/mellanox/mlx4/main.c          |    2 +
 drivers/net/ethernet/mellanox/mlx4/qp.c            |    5 ++
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    6 ++-
 include/linux/mlx4/device.h                        |   17 +++++
 include/linux/mlx4/qp.h                            |   14 +++-
 include/linux/netdevice.h                          |    9 +++
 net/core/net-sysfs.c                               |   70 ++++++++++++++++----
 10 files changed, 168 insertions(+), 18 deletions(-)
