From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] [NET] reduce sizeof(struct flowi) by 20 bytes
Date: Fri, 20 Oct 2006 15:55:33 +0200
Message-ID: <200610201555.33736.dada1@cosmosbay.com>
References: <4535B6B7.4070107@cosmosbay.com> <200610181055.32102.dada1@cosmosbay.com> <20061018124202.GA31981@fogou.chygwyn.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_VVNOFZHnQfQVJgf"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:14498 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S2992615AbWJTNzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 09:55:33 -0400
To: Steven Whitehouse <steve@chygwyn.com>,
	David Miller <davem@davemloft.net>
In-Reply-To: <20061018124202.GA31981@fogou.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_VVNOFZHnQfQVJgf
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi all

As suggested by David, just kill off some unused fields in dnports to reduce 
sizef(struct flowi). If they come back, they should be moved to nl_u.dn_u in 
order not to enlarge again struct flowi

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--Boundary-00=_VVNOFZHnQfQVJgf
Content-Type: text/plain;
  charset="iso-8859-1";
  name="shrink_flowi.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="shrink_flowi.patch"

diff --git a/include/net/dn.h b/include/net/dn.h
index 465b783..c39385b 100644
--- a/include/net/dn.h
+++ b/include/net/dn.h
@@ -199,11 +199,13 @@ static inline void dn_sk_ports_copy(stru
 {
 	fl->uli_u.dnports.sport = scp->addrloc;
 	fl->uli_u.dnports.dport = scp->addrrem;
+#if 0 /* not yet used */
 	fl->uli_u.dnports.objnum = scp->addr.sdn_objnum;
 	if (fl->uli_u.dnports.objnum == 0) {
 		fl->uli_u.dnports.objnamel = (__u8)dn_ntohs(scp->addr.sdn_objnamel);
 		memcpy(fl->uli_u.dnports.objname, scp->addr.sdn_objname, 16);
 	}
+#endif
 }
 
 extern unsigned dn_mss_from_pmtu(struct net_device *dev, int mtu);
diff --git a/include/net/flow.h b/include/net/flow.h
index 3b44d72..bdc0e49 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -68,9 +68,11 @@ #define FLOWI_FLAG_MULTIPATHOLDROUTE 0x0
 		struct {
 			__le16	sport;
 			__le16	dport;
+#if 0 /* not yet used, should move to nl_u.dn_u */
 			__u8	objnum;
 			__u8	objnamel; /* Not 16 bits since max val is 16 */
 			__u8	objname[16]; /* Not zero terminated */
+#endif
 		} dnports;
 
 		__be32		spi;

--Boundary-00=_VVNOFZHnQfQVJgf--
