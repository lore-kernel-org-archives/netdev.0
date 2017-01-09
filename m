From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net] mlx4: Return EOPNOTSUPP instead of ENOTSUPP
Date: Mon, 9 Jan 2017 14:13:59 -0800
Message-ID: <1484000039-671014-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46981 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932080AbdAIWOC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 17:14:02 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v09ME1xd013369
        for <netdev@vger.kernel.org>; Mon, 9 Jan 2017 14:14:02 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 27vj4bgdpr-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 14:14:02 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 ec39bc32d6b811e6a4870002c991e86a-abacca50 for <netdev@vger.kernel.org>;        Mon,
 09 Jan 2017 14:14:00 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit b45f0674b997 ("mlx4: xdp: Allow raising MTU up to one page minus eth and vlan hdrs"),
it changed ENOTSUPP to EOPNOTSUPP by mistake.  This patch fixes it.

Fixes: b45f0674b997 ("mlx4: xdp: Allow raising MTU up to one page minus eth and vlan hdrs")
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index edbe200ac2fa..4910d9af1933 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2277,7 +2277,7 @@ static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
 
 	if (priv->tx_ring_num[TX_XDP] &&
 	    !mlx4_en_check_xdp_mtu(dev, new_mtu))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	dev->mtu = new_mtu;
 
-- 
2.5.1
