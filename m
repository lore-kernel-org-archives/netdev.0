From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] loopback: sctp: add NETIF_F_SCTP_CSUM to device features
Date: Sat, 22 Feb 2014 14:01:53 +0100
Message-ID: <1393074113-9922-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751173AbaBVNB4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Feb 2014 08:01:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drivers are allowed to set NETIF_F_SCTP_CSUM if they have
hardware crc32c checksumming support for the SCTP protocol.
Currently, NETIF_F_SCTP_CSUM flag is available in igb,
ixgbe, i40e/i40evf drivers and for vlan devices.

If we don't have NETIF_F_SCTP_CSUM then crc32c is done
through CPU instructions, invoked from crypto layer, or
if not available as slow-path fallback in software.

Currently, loopback device propagates checksum offloading
feature flags in dev->features, but is missing SCTP checksum
offloading. Therefore, account for NETIF_F_SCTP_CSUM as
well.

Before patch:

./netperf_sctp -H 192.168.0.100 -t SCTP_STREAM_MANY
SCTP 1-TO-MANY STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.0.100 () port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

4194304 4194304   4096    10.00    4683.50

After patch:

./netperf_sctp -H 192.168.0.100 -t SCTP_STREAM_MANY
SCTP 1-TO-MANY STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.0.100 () port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

4194304 4194304   4096    10.00    15348.26

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 drivers/net/loopback.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 771c9bf..282effe 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -176,6 +176,7 @@ static void loopback_setup(struct net_device *dev)
 		| NETIF_F_UFO
 		| NETIF_F_HW_CSUM
 		| NETIF_F_RXCSUM
+		| NETIF_F_SCTP_CSUM
 		| NETIF_F_HIGHDMA
 		| NETIF_F_LLTX
 		| NETIF_F_NETNS_LOCAL
-- 
1.7.11.7
