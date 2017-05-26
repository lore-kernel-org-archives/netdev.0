From: Jes Sorensen <jes.sorensen@gmail.com>
Subject: [PATCH 0/7] mlx5: Make eswitch_offloads a compile option
Date: Fri, 26 May 2017 17:16:17 -0400
Message-ID: <20170526211624.23133-1-jsorensen@fb.com>
Cc: kernel-team@fb.com, saeedm@mellanox.com, ilant@mellanox.com,
        Jes Sorensen <jsorensen@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:33279 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948718AbdEZVQe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 17:16:34 -0400
Received: by mail-yw0-f196.google.com with SMTP id y64so1358383ywe.0
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 14:16:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This changes the code to allow for eswitch_offloads to be compile time
option, reducing the size of the driver module for those who do not
need it.

The patches do it step by step by introducing stubs and then finally
gets rid of all the #ifdefs once the code can compile and link without
including eswitch_offloads.o

Unlike the patches that were discussed on the list back in January,
this does not try to remove eswitch support. It simply allows the
offloads to be disabled.

Cheers,
Jes


Jes Sorensen (7):
  mlx5: Allow support for eswitch offloads to be disabled
  mlx5: eswitch vlan functionality is only called if SRIOV_OFFLOADS is
    set
  mlx5: Disable {add,del}_offloaded_rule() code if eswitch offloads are
    disabled
  mlx5: Stub out eswitch offload vport functions
  mlx5: Stub out create_vport_rx_rule when eswitch_offloads disabled
  mlx5: Stub out sqs2vport functions
  mlx5: Do not build eswitch_offloads if CONFIG_MLX5_EN_ESWITCH_OFFLOADS
    is set

 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    | 10 +++
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |  4 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  | 80 +++++++++++++++++++++-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  2 +-
 5 files changed, 94 insertions(+), 3 deletions(-)

-- 
2.9.4
