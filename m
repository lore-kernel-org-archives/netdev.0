From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 2/2] ibmveth: make sure skb is not null
Date: Tue, 20 May 2008 17:23:44 +0800
Message-ID: <483298A0.20405@cn.fujitsu.com>
References: <48329650.60809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: santil@us.ibm.com, "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52046 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758599AbYETJ0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 05:26:23 -0400
In-Reply-To: <48329650.60809@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no assurance to guarantee ibmveth_rxq_get_buffer won't return a NULL.
So add an assertion here.

No device, not tested.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/ibmveth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 0052780..9d1523a 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -945,6 +945,7 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
 			int csum_good = ibmveth_rxq_csum_good(adapter);
 
 			skb = ibmveth_rxq_get_buffer(adapter);
+			ibmveth_assert(skb != NULL);
 			if (csum_good)
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-- 
1.5.3.4

