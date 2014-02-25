From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/3] net, net/mlx4: Add sysfs file for port number
Date: Tue, 25 Feb 2014 18:17:49 +0200
Message-ID: <1393345072-31584-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Jordan_Hargrave@Dell.com, Narendra_K@Dell.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:45662 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752619AbaBYQSn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 11:18:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Modern distro's are using biosdevname to rename interface to a name based on
slot/port number.
biosdevname can't get the port number of devices that have multiple ports that
share the same PCI function.
This patch adds a sysfs file under: /sys/devices/.../net/<interface>/dev_port,
that contains the port number (0 based) - to be used by biosdevname.
Also, dev_id was wrongly used in mlx4_en driver - added a patch that fix it.

This patch was tested and applied over commit 51adfcc "net: bcmgenet: remove
unused bh_lock member"

Amir

CC: Jordan_Hargrave@Dell.com 
CC: Narendra_K@Dell.com

Amir Vadai (3):
  net: Add sysfs file for port number
  net/mlx4_en: Expose port number through sysfs
  net/mlx4_en: Fix bad use of dev_id

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 2 +-
 include/linux/netdevice.h                      | 4 ++++
 net/core/net-sysfs.c                           | 2 ++
 3 files changed, 7 insertions(+), 1 deletion(-)

-- 
1.8.3.4
