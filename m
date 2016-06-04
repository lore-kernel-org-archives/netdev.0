From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 20/29] net/sctp/output.c:185:21: warning:
 format '%lu' expects argument of type 'long unsigned int', but argument 4
 has type 'size_t {aka unsigned int}'
Date: Fri, 03 Jun 2016 22:53:53 -0700 (PDT)
Message-ID: <20160603.225353.2112286833349209535.davem@davemloft.net>
References: <201606041010.Uqa8jrpA%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	marcelo.leitner@gmail.com
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbcFDFx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 01:53:56 -0400
In-Reply-To: <201606041010.Uqa8jrpA%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I fixed this as follows:

====================
[PATCH] sctp: Fix warning in sctp_packet_transmit_chunk()

size_t objects should be printed with %Z printf format.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sctp/output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 90d2e12..1541a91 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -182,7 +182,7 @@ sctp_xmit_t sctp_packet_transmit_chunk(struct sctp_packet *packet,
 	sctp_xmit_t retval;
 	int error = 0;
 
-	pr_debug("%s: packet:%p size:%lu chunk:%p size:%d\n", __func__,
+	pr_debug("%s: packet:%p size:%Zu chunk:%p size:%d\n", __func__,
 		 packet, packet->size, chunk, chunk->skb ? chunk->skb->len : -1);
 
 	switch ((retval = (sctp_packet_append_chunk(packet, chunk)))) {
-- 
2.1.0
