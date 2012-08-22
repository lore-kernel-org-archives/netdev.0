From: pablo@netfilter.org
Subject: [PATCH 01/10] ipvs: ip_vs_ftp depends on nf_conntrack_ftp helper
Date: Thu, 23 Aug 2012 01:38:37 +0200
Message-ID: <1345678726-3109-2-git-send-email-pablo@netfilter.org>
References: <1345678726-3109-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345678726-3109-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

	The FTP application indirectly depends on the
nf_conntrack_ftp helper for proper NAT support. If the
module is not loaded, IPVS can resize the packets for the
command connection, eg. PASV response but the SEQ adjustment
logic in ipv4_confirm is not called without helper.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/Kconfig |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index f987138..8b2cffd 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -250,7 +250,8 @@ comment 'IPVS application helper'
 
 config	IP_VS_FTP
   	tristate "FTP protocol helper"
-        depends on IP_VS_PROTO_TCP && NF_CONNTRACK && NF_NAT
+	depends on IP_VS_PROTO_TCP && NF_CONNTRACK && NF_NAT && \
+		NF_CONNTRACK_FTP
 	select IP_VS_NFCT
 	---help---
 	  FTP is a protocol that transfers IP address and/or port number in
-- 
1.7.10.4

