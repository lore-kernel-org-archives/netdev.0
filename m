From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH net] veth: add vlan features
Date: Thu, 18 Jul 2013 16:15:11 -0300
Message-ID: <1374174911-6435-1-git-send-email-fbl@redhat.com>
Cc: Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55630 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933119Ab3GRTPX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jul 2013 15:15:23 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r6IJFLcc021604
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 18 Jul 2013 15:15:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The veth device doesn't provide the vlan features,
so TSO for example is disabled and that causes
performance issues when using tagged traffic.

The test topology looks like this:

    br0                     br1
  /   \                  /     \
vnet  veth0.10 ----- veth1.10   vnet
VM                               VM

The netperf results with current veth driver:
MIGRATED TCP STREAM TEST from 192.168.1.1 ()
port 0 AF_INET to 192.168.1.2 () port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.01    2210.22

Now after applying the proposed patch:
MIGRATED TCP STREAM TEST from 192.168.1.1 ()
port 0 AF_INET to 192.168.1.2 () port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    13067.47

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 drivers/net/veth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index da86652..eee1f19 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -269,6 +269,7 @@ static void veth_setup(struct net_device *dev)
 	dev->ethtool_ops = &veth_ethtool_ops;
 	dev->features |= NETIF_F_LLTX;
 	dev->features |= VETH_FEATURES;
+	dev->vlan_features = dev->features;
 	dev->destructor = veth_dev_free;
 
 	dev->hw_features = VETH_FEATURES;
-- 
1.8.3.1
