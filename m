From: Ian Kumlien <ian.kumlien@gmail.com>
Subject: Re: [RFC] change the default Kconfig value of mlx5_en
Date: Sat, 22 Apr 2017 01:10:44 +0200
Message-ID: <CAA85sZtr3N3Y8=R5qZHDTMgquV35ddw0x45qy8Kkf_tiVdu8ag@mail.gmail.com>
References: <CAA85sZumYPfUg_yA=5azrHneqq-XBmHiGNgRaEvBwbewVRj11w@mail.gmail.com>
 <20170421.154745.182611990085743539.davem@davemloft.net> <CAA85sZtBo5dORg4sj8X_SROBU0ySh3_CQh1WiYcVX-RVv4E+gA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: saeedm@mellanox.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34029 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1422875AbdDUXLG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 19:11:06 -0400
Received: by mail-lf0-f68.google.com with SMTP id x72so10959620lfb.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 16:11:05 -0700 (PDT)
In-Reply-To: <CAA85sZtBo5dORg4sj8X_SROBU0ySh3_CQh1WiYcVX-RVv4E+gA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry,

Back again, fighting cold, hot whiskey has been consumed...

Something like this would perhaps be a better solution:

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c
b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 60154a175bd3..fe192e247601 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1139,6 +1139,10 @@ static int mlx5_load_one(struct mlx5_core_dev
*dev, struct mlx5_priv *priv,

 #ifdef CONFIG_MLX5_CORE_EN
        mlx5_eswitch_attach(dev->priv.eswitch);
+#else
+       if (MLX5_CAP_GEN(dev, port_type) == MLX5_CAP_PORT_TYPE_ETH) {
+               dev_info(&pdev->dev, "Ethernet device discovered but
support not enabled in kernel.");
+       }
 #endif

        err = mlx5_sriov_attach(dev);

This is in no way tested and just a thought for now - I suspect that a
better message would be required though...
