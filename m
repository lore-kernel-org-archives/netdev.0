From: Andreas Bardoutsos <bardoutsos@ceid.upatras.gr>
Subject: [[NET-NEXT]] Added dump function to recognise rpl extension header
 option(63)
Date: Thu, 04 May 2017 14:06:32 +0200
Message-ID: <a712ff423471e02a533650ce6d64dc85@ceid.upatras.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Richardson <mcr@sandelman.ca>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poseidon.ceid.upatras.gr ([150.140.141.169]:47278 "EHLO
        poseidon.ceid.upatras.gr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752401AbdEDMMK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 08:12:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andreas Bardoutsos <bardoutsos@ceid.upatras.gr>
---
I have added a dump function(always return true) to recognise RPL 
extension header(RFC6553)
Otherwise packet was dropped by kernel resulting in impossible 
communication in RPL DAG's between
linux running border routers and devices in the graph,which may run 
different OS(contiki os for example)

  include/uapi/linux/in6.h |  1 +
  net/ipv6/exthdrs.c       | 13 +++++++++++++
  2 files changed, 14 insertions(+)

diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index 46444f8fbee4..5cc12d309dfe 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -146,6 +146,7 @@ struct in6_flowlabel_req {
  #define IPV6_TLV_CALIPSO	7	/* RFC 5570 */
  #define IPV6_TLV_JUMBO		194
  #define IPV6_TLV_HAO		201	/* home address option */
+#define IPV6_TLV_RPL	99	/* RFC 6553 */

  /*
   *	IPV6 socket options
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index b636f1da9aec..82ed60d3180e 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -785,6 +785,15 @@ static bool ipv6_hop_calipso(struct sk_buff *skb, 
int optoff)
  	return false;
  }

+/* RPL RFC 6553 */
+
+static bool ipv6_hop_rpl(struct sk_buff *skb, int optoff)
+{
+	/*Dump function which always return true
+	*when rpl option is detected*/
+	return true;
+}
+
  static const struct tlvtype_proc tlvprochopopt_lst[] = {
  	{
  		.type	= IPV6_TLV_ROUTERALERT,
@@ -798,6 +807,10 @@ static const struct tlvtype_proc 
tlvprochopopt_lst[] = {
  		.type	= IPV6_TLV_CALIPSO,
  		.func	= ipv6_hop_calipso,
  	},
+	{
+		.type	= IPV6_TLV_RPL,
+		.func	= ipv6_hop_rpl,
+	},
  	{ -1, }
  };
