From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 01/33] nf_conntrack_sip: de-static helper pointers
Date: Mon,  8 Sep 2008 07:02:38 +0400
Message-ID: <1220842990-30500-1-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

->help hook can run concurrently with itself, so iterating over SIP helpers
with static pointer can't work reliably.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 2f9bbc0..1fa306b 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1193,7 +1193,6 @@ static const struct sip_handler sip_handlers[] = {
 static int process_sip_response(struct sk_buff *skb,
 				const char **dptr, unsigned int *datalen)
 {
-	static const struct sip_handler *handler;
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	unsigned int matchoff, matchlen;
@@ -1214,6 +1213,8 @@ static int process_sip_response(struct sk_buff *skb,
 	dataoff = matchoff + matchlen + 1;
 
 	for (i = 0; i < ARRAY_SIZE(sip_handlers); i++) {
+		const struct sip_handler *handler;
+
 		handler = &sip_handlers[i];
 		if (handler->response == NULL)
 			continue;
@@ -1228,13 +1229,14 @@ static int process_sip_response(struct sk_buff *skb,
 static int process_sip_request(struct sk_buff *skb,
 			       const char **dptr, unsigned int *datalen)
 {
-	static const struct sip_handler *handler;
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	unsigned int matchoff, matchlen;
 	unsigned int cseq, i;
 
 	for (i = 0; i < ARRAY_SIZE(sip_handlers); i++) {
+		const struct sip_handler *handler;
+
 		handler = &sip_handlers[i];
 		if (handler->request == NULL)
 			continue;
