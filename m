From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH] bpf: fix implicit declaration of bpf_prog_add
Date: Wed, 20 Jul 2016 07:55:52 -0700
Message-ID: <1469026552-8975-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35874 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754371AbcGTO42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 10:56:28 -0400
Received: by mail-pa0-f51.google.com with SMTP id pp5so19072608pac.3
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 07:56:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the ifndef case of CONFIG_BPF_SYSCALL, an inline version of
bpf_prog_add needs to exist otherwise the build breaks on some configs.

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c:2544:10: error: implicit declaration of function 'bpf_prog_add'
       prog = bpf_prog_add(prog, priv->rx_ring_num - 1);

The function is introduced in
59d3656d5bf50 ("bpf: add bpf_prog_add api for bulk prog refcnt")
and first used in
47f1afdba2b87 ("net/mlx4_en: add support for fast rx drop bpf program").

Fixes: 47f1afdba2b87 ("net/mlx4_en: add support for fast rx drop bpf program")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Reported-by: Tariq Toukan <ttoukan.linux@gmail.com>
Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 include/linux/bpf.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 75a5ae6..36da074 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -289,6 +289,10 @@ static inline struct bpf_prog *bpf_prog_get_type(u32 ufd,
 {
 	return ERR_PTR(-EOPNOTSUPP);
 }
+static inline struct bpf_prog *bpf_prog_add(struct bpf_prog *prog, int i)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
 
 static inline void bpf_prog_put(struct bpf_prog *prog)
 {
-- 
2.8.2
