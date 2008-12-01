From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH] lro: IP fragment checking
Date: Mon, 01 Dec 2008 09:58:55 +0100
Message-ID: <4933A74F.3050809@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>, tklein@de.ibm.com,
	Christoph Raisch <raisch@de.ibm.com>, jb.billaud@gmail.com,
	hering2@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:46685 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070AbYLAI65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 03:58:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prevents that ip fragmented TCP packets are considered vaild
for aggregation

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





