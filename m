From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net v2 0/2] mlx4: Misc bug fixes after reinitializing queues
Date: Tue, 31 Jan 2017 22:35:31 -0800
Message-ID: <1485930933-4159518-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:35229 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751004AbdBAGfh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 01:35:37 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v116ZYPi011340
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 22:35:36 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 28badcr0kt-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 22:35:36 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 a2397de2e84811e6934024be0593f280-98b826d0 for <netdev@vger.kernel.org>;        Tue,
 31 Jan 2017 22:35:33 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes misc bugs after reinitializing
queues (e.g. by ethtool -L).

v2:
* Add another fix to mem leak in tx_ring[t] and tx_cq[t]
* In mlx4_en_try_alloc_resources(),
  move all xdp_prog logic after calling mlx4_en_alloc_resources()

Martin KaFai Lau (2):
  mlx4: Fix memory leak after mlx4_en_update_priv()
  mlx4: xdp_prog becomes inactive after mlx4_en_try_alloc_resources()

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  4 +--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 35 ++++++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  3 ++-
 3 files changed, 29 insertions(+), 13 deletions(-)

-- 
2.5.1
