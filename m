From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH v2 ethtool] ethtool: Remove UDP Fragmentation Offload error prints
Date: Mon, 18 Sep 2017 10:35:38 +0300
Message-ID: <1505720138-14416-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Michal Kubecek <mkubecek@suse.cz>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Shaker Daibes <shakerd@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60376 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752600AbdIRHgP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 03:36:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaker Daibes <shakerd@mellanox.com>

UFO was removed in kernel, here we remove UFO error prints when using
"ethtool -k" command.

Fixes the following issue:
Features for ens8:
Cannot get device udp-fragmentation-offload settings: Operation not
supported

Signed-off-by: Shaker Daibes <shakerd@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 ethtool.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ethtool.c b/ethtool.c
index ad18704e7c5f..aeeef65e7ef3 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2186,6 +2186,10 @@ get_features(struct cmd_context *ctx, const struct feature_defs *defs)
 		eval.cmd = off_flag_def[i].get_cmd;
 		err = send_ioctl(ctx, &eval);
 		if (err) {
+			if (errno == EOPNOTSUPP &&
+			    off_flag_def[i].get_cmd == ETHTOOL_GUFO)
+				continue;
+
 			fprintf(stderr,
 				"Cannot get device %s settings: %m\n",
 				off_flag_def[i].long_name);
-- 
1.8.3.1
