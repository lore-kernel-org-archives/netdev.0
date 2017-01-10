From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net v2] mlx4: Return EOPNOTSUPP instead of ENOTSUPP
Date: Tue, 10 Jan 2017 09:41:49 -0800
Message-ID: <1484070109-105991-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:45479 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754262AbdAJRlw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 12:41:52 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0AHdcQP018956
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 09:41:51 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 27vvx531jv-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 09:41:51 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 10a490d0d75c11e6aaae24be0593f280-2a0d9a50 for <netdev@vger.kernel.org>;        Tue,
 10 Jan 2017 09:41:49 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit b45f0674b997 ("mlx4: xdp: Allow raising MTU up to one page minus eth and vlan hdrs"),
it changed EOPNOTSUPP to ENOTSUPP by mistake.  This patch fixes it.

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
