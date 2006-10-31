From: James Morris <jmorris@namei.org>
Subject: [PATCH] ipv6: return EINVAL for invalid address with flowlabel lease
 request
Date: Mon, 30 Oct 2006 19:31:31 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0610301914230.10915@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:60824 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1161481AbWJaAbd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 19:31:33 -0500
To: =?iso-2022-jp?Q?YOSHIFUJI_Hideaki_=2F_=B5=C8=C6=A3=B1=D1=CC=C0?=
	<yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, when an application requests a lease for a flowlabel via the 
IPV6_FLOWLABEL_MGR socket option, no error is returned if an invalid type 
of destination address is supplied as part of the request, leading to a 
silent failure.  This patch ensures that EINVAL is returned to the 
application in this case.

Please apply.

Signed-off-by: James Morris <jmorris@namei.org>

---

 net/ipv6/ip6_flowlabel.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff -purN -X dontdiff linux-2.6.p/net/ipv6/ip6_flowlabel.c linux-2.6.w/net/ipv6/ip6_flowlabel.c
--- linux-2.6.p/net/ipv6/ip6_flowlabel.c	2006-10-30 18:30:34.000000000 -0500
+++ linux-2.6.w/net/ipv6/ip6_flowlabel.c	2006-10-30 18:57:33.000000000 -0500
@@ -330,8 +330,10 @@ fl_create(struct in6_flowlabel_req *freq
 	fl->share = freq->flr_share;
 	addr_type = ipv6_addr_type(&freq->flr_dst);
 	if ((addr_type&IPV6_ADDR_MAPPED)
-	    || addr_type == IPV6_ADDR_ANY)
+	    || addr_type == IPV6_ADDR_ANY) {
+		err = -EINVAL;
 		goto done;
+	}
 	ipv6_addr_copy(&fl->dst, &freq->flr_dst);
 	atomic_set(&fl->users, 1);
 	switch (fl->share) {
