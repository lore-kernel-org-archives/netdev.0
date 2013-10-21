From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH 3/3] bnx2x: add TSO support for SIT tunnels
Date: Sun, 20 Oct 2013 20:47:31 -0700
Message-ID: <1382327251-21079-4-git-send-email-edumazet@google.com>
References: <1382327251-21079-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Erik Kline <ek@google.com>, Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f202.google.com ([209.85.128.202]:64760 "EHLO
	mail-ve0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461Ab3JUDrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 23:47:53 -0400
Received: by mail-ve0-f202.google.com with SMTP id c14so513717vea.3
        for <netdev@vger.kernel.org>; Sun, 20 Oct 2013 20:47:52 -0700 (PDT)
In-Reply-To: <1382327251-21079-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x driver already handles TSO for GRE and IPIP, current code
is the same for SIT.

Performance results : (Note we are now limited by receiver,
as it does not support GRO for SIT yet)

Before patch :

lpq84:~# ./netperf -H 2002:af6:1153:: -Cc
MIGRATED TCP STREAM TEST from ::0 (::) port 0 AF_INET6 to 2002:af6:1153:: () port 0 AF_INET6
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.00      5525.00   7.76     5.17     2.763   1.840

lpq84:~# ./netperf -H 2002:af6:1153:: -Cc
MIGRATED TCP STREAM TEST from ::0 (::) port 0 AF_INET6 to 2002:af6:1153:: () port 0 AF_INET6
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.00      6006.97   1.86     5.48     0.608   1.795

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 6e5b35f..04b9177 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12261,11 +12261,12 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 		NETIF_F_RXHASH | NETIF_F_HW_VLAN_CTAG_TX;
 	if (!CHIP_IS_E1x(bp)) {
 		dev->hw_features |= NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL |
-				    NETIF_F_GSO_IPIP;
+				    NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT;
 		dev->hw_enc_features =
 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
 			NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
 			NETIF_F_GSO_IPIP |
+			NETIF_F_GSO_SIT |
 			NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL;
 	}
 
-- 
1.8.4
