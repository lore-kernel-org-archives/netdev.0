From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] veth: sctp: add NETIF_F_SCTP_CRC to device features
Date: Thu, 25 Aug 2016 13:21:49 +0800
Message-ID: <3b9880c091c96f4e6780b96b4f3e2c4d38dffe42.1472102509.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36725 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753783AbcHYFV4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 01:21:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit b17c706987fa ("loopback: sctp: add NETIF_F_SCTP_CSUM to device
features") added NETIF_F_SCTP_CRC to device features for lo device to
improve the performance of sctp over lo.

This patch is to add NETIF_F_SCTP_CRC to device features for veth to
improve the performance of sctp over veth.

Before this patch:
  ip netns exec cs_client netperf -H 10.167.12.2 -t SCTP_STREAM -- -m 10K
  Recv   Send    Send
  Socket Socket  Message  Elapsed
  Size   Size    Size     Time     Throughput
  bytes  bytes   bytes    secs.    10^6bits/sec

  212992 212992  10240    10.00    1117.16

After this patch:
  ip netns exec cs_client netperf -H 10.167.12.2 -t SCTP_STREAM -- -m 10K
  Recv   Send    Send
  Socket Socket  Message  Elapsed
  Size   Size    Size     Time     Throughput
  bytes  bytes   bytes    secs.    10^6bits/sec

  212992 212992  10240    10.20    1415.22

Tested-by: Li Shuang <tjlishuang@yeah.net>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 drivers/net/veth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index f37a6e6..4bda502 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -313,7 +313,7 @@ static const struct net_device_ops veth_netdev_ops = {
 };
 
 #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HW_CSUM | \
-		       NETIF_F_RXCSUM | NETIF_F_HIGHDMA | \
+		       NETIF_F_RXCSUM | NETIF_F_SCTP_CRC | NETIF_F_HIGHDMA | \
 		       NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ENCAP_ALL | \
 		       NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX | \
 		       NETIF_F_HW_VLAN_STAG_TX | NETIF_F_HW_VLAN_STAG_RX )
-- 
2.1.0
