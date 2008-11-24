From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [RFC PATCH] lro: ip fragment checking
Date: Mon, 24 Nov 2008 16:56:52 +0100
Message-ID: <492ACEC4.3020702@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, tklein@de.ibm.com,
	Christoph Raisch <raisch@de.ibm.com>, jb.billaud@gmail.com,
	hering2@de.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:41279 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945AbYKXP4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 10:56:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there is no checking in the LRO receive path whether
TCP packets are ip fragmented. We should not consider
those packets for aggregation.
I'm not sure if this checking is actually required. Does anyone
know if it is possible to get fragmented TCP packets without
the tcp stack changing the MSS size?
This patch introduces explicit checking. Any objections?

Regards,

Jan-Bernd

---



 net/ipv4/inet_lro.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index cfd034a..1f9159d 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -64,6 +64,9 @@ static int lro_tcp_ip_check(struct iphdr *iph, struct tcphdr *tcph,
 	if (iph->ihl != IPH_LEN_WO_OPTIONS)
 		return -1;
 
+	if (iph->frag_off & IP_MF)
+		return -1;
+
 	if (tcph->cwr || tcph->ece || tcph->urg || !tcph->ack
 	    || tcph->rst || tcph->syn || tcph->fin)
 		return -1;
-- 
1.5.5




