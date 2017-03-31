From: akpm@linux-foundation.org
Subject: [patch 2/2] drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c: fix build with gcc-4.4.4
Date: Fri, 31 Mar 2017 13:09:41 -0700
Message-ID: <58deb785.KVe23DdxZZyNjqm4%akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: saeedm@mellanox.com, netdev@vger.kernel.org,
        akpm@linux-foundation.org, tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:49366 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933339AbdCaUJl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 16:09:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Subject: drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c: fix build with gcc-4.4.4

drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c: In function 'mlx5e_set_rxfh':
drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c:1067: error: unknown field 'rss' specified in initializer
drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c:1067: warning: missing braces around initializer
drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c:1067: warning: (near initialization for 'rrp.<anonymous>')
drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c:1068: error: unknown field 'rss' specified in initializer
drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c:1069: warning: excess elements in struct initializer
drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c:1069: warning: (near initialization for 'rrp')

gcc-4.4.4 has issues with anonymous union initializers.  Work around this.

Cc: Saeed Mahameed <saeedm@mellanox.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff -puN drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c~drivers-net-ethernet-mellanox-mlx5-core-en_ethtoolc-fix-build-with-gcc-444 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c~drivers-net-ethernet-mellanox-mlx5-core-en_ethtoolc-fix-build-with-gcc-444
+++ a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -1064,8 +1064,12 @@ static int mlx5e_set_rxfh(struct net_dev
 			u32 rqtn = priv->indir_rqt.rqtn;
 			struct mlx5e_redirect_rqt_param rrp = {
 				.is_rss = true,
-				.rss.hfunc = priv->channels.params.rss_hfunc,
-				.rss.channels  = &priv->channels
+				{
+					.rss = {
+						.hfunc = priv->channels.params.rss_hfunc,
+						.channels  = &priv->channels,
+					},
+				},
 			};
 
 			mlx5e_redirect_rqt(priv, rqtn, MLX5E_INDIR_RQT_SIZE, rrp);
_
