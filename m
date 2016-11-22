From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: mlx5 "syndrome" errors in kernel log
Date: Tue, 22 Nov 2016 10:59:44 +0100
Message-ID: <20161122105944.0c64e77b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46696 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755650AbcKVJ7w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 04:59:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Saeed,

I'm seeing below dmesg errors, after pulling net-next at commit
e796f49d826aad, before I was not seeing these errors, where my tree was
based on top of commit 319b0534b95.

mlx5_core 0000:02:00.1: mlx5_cmd_check:698:(pid 8788): ACCESS_REG(0x805) op_mod(0x1) failed, status bad parameter(0x3), syndrome (0x6c4d48)
mlx5_core 0000:02:00.1: mlx5_cmd_check:698:(pid 8788): ACCESS_REG(0x805) op_mod(0x1) failed, status bad parameter(0x3), syndrome (0x6c4d48)
mlx5_core 0000:02:00.0: mlx5_cmd_check:698:(pid 8788): ACCESS_REG(0x805) op_mod(0x1) failed, status bad parameter(0x3), syndrome (0x6c4d48)
mlx5_core 0000:02:00.0: mlx5_cmd_check:698:(pid 8788): ACCESS_REG(0x805) op_mod(0x1) failed, status bad parameter(0x3), syndrome (0x6c4d48)
mlx5_core 0000:02:00.1: mlx5_cmd_check:698:(pid 8788): ACCESS_REG(0x805) op_mod(0x1) failed, status bad parameter(0x3), syndrome (0x6c4d48)
mlx5_core 0000:02:00.1: mlx5_cmd_check:698:(pid 8788): ACCESS_REG(0x805) op_mod(0x1) failed, status bad parameter(0x3), syndrome (0x6c4d48)
mlx5_core 0000:02:00.0: mlx5_cmd_check:698:(pid 8788): ACCESS_REG(0x805) op_mod(0x1) failed, status bad parameter(0x3), syndrome (0x6c4d48)
mlx5_core 0000:02:00.0: mlx5_cmd_check:698:(pid 8788): ACCESS_REG(0x805) op_mod(0x1) failed, status bad parameter(0x3), syndrome (0x6c4d48)


Listing my firmware version:

 $ ethtool -i mlx5p2
 driver: mlx5_core
 version: 3.0-1 (January 2015)
 firmware-version: 12.12.1240
 bus-info: 0000:02:00.1
 supports-statistics: yes
 supports-test: no
 supports-eeprom-access: no
 supports-register-dump: no
 supports-priv-flags: yes

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


git diff --stat 319b0534b95..e796f49d826aad drivers/net/ethernet/mellanox/mlx5/
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c        | 145 ++++++++++++++++++++++++++++++++++++++++++----------------------------------------------
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c |  40 ++++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c    |  61 +++++++++++++++++++++++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h   |  49 +++++++++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c         |  12 ++++++++
 drivers/net/ethernet/mellanox/mlx5/core/main.c       |  37 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h  |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/port.c       |  57 +++++++++++++++++++++++++++++++++++
 8 files changed, 312 insertions(+), 90 deletions(-)


$ git shortlog  319b0534b95..e796f49d826aad drivers/net/ethernet/mellanox/mlx5/
Daniel Borkmann (3):
      bpf, mlx5: fix mlx5e_create_rq taking reference on prog
      bpf, mlx5: fix various refcount issues in mlx5e_xdp_set
      bpf, mlx5: drop priv->xdp_prog reference on netdev cleanup

Eric Dumazet (1):
      net/mlx5e: remove napi_hash_del() calls

Gal Pressman (1):
      net/mlx5e: Expose PCIe statistics to ethtool

Huy Nguyen (3):
      net/mlx5: Add handling for port module event
      net/mlx5e: Add port module event counters to ethtool stats
      net/mlx5: Set driver version into firmware

Mohamad Haj Yahia (1):
      net/mlx5: Make the command interface cache more flexible



$ git log --pretty=oneline   319b0534b95..e796f49d826aad drivers/net/ethernet/mellanox/mlx5/
a055c19be98bc065a4478663ba7f6833693b8958 bpf, mlx5: drop priv->xdp_prog reference on netdev cleanup
c54c06290428554bc0e26d58f21a7865cbe995af bpf, mlx5: fix various refcount issues in mlx5e_xdp_set
97bc402db7821259f6a722cb38e060aa9b35b6e8 bpf, mlx5: fix mlx5e_create_rq taking reference on prog
9c7262399ba12825f3ca4b00a76d8d5e77c720f5 net/mlx5e: Expose PCIe statistics to ethtool
012e50e109fd27ff989492ad74c50ca7ab21e6a1 net/mlx5: Set driver version into firmware
bedb7c909c1911270fcb084230245df4a00bd881 net/mlx5e: Add port module event counters to ethtool stats
d4eb4cd78b0774c7061db56844ed2ea7790cc77c net/mlx5: Add handling for port module event
0ac3ea70897fb9f84b620aeda074ecccf481629d net/mlx5: Make the command interface cache more flexible
d30d9ccbfac7cf9a12a088d57aaf0891732e2bca net/mlx5e: remove napi_hash_del() calls
