From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/3] Make is_kdump_kernel() accessible from modules
Date: Sun, 27 Jul 2014 17:59:13 +0300
Message-ID: <1406473156-4077-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vivek Goyal <vgoyal@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:53394 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752007AbaG0O7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jul 2014 10:59:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm sending this patchset to net-next because it touches a commit [1] that was
applied lately to net-next.

Drivers need to know if running from kdump kernel in order to change their
memory profile - since kdump environment is limited by available memory.
Currently there are drivers that are using reset_devices as suggested in [2].
In [2] it was suggested to use reset_devices, but the context was, to enable
driver to know when the hardware device is needed to be reset, and not if this
is a kdump environment. We think that is_kdump_kernel() is better suited to
select between different memory profiles.

The first patch in this patchset exports a needed symbol in order to make
is_kdump_kernel() accessible from the drivers. The rest of the patches change
from reset_devices to is_kdump_kernel() in 2 networking drivers.

The idea of this patchset was suggested by Vivek Goyal.

Tested and applied on top of commit f6e6753 ("Merge branch 'filter-move'")

[1] - ea1c1af: ("net/mlx4_en: Reduce memory consumption on kdump kernel")
[2] - https://lkml.org/lkml/2011/1/27/341

Thanks,
Amir

Amir Vadai (3):
  crash_dump: Make is_kdump_kernel() accessible from modules
  net/mlx4: Use is_kdump_kernel() to detect kdump kernel
  net/bnx2x: Use is_kdump_kernel() to detect kdump kernel

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 3 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 3 ++-
 include/linux/mlx4/device.h                      | 3 ++-
 kernel/crash_dump.c                              | 1 +
 4 files changed, 7 insertions(+), 3 deletions(-)

-- 
1.8.3.4
