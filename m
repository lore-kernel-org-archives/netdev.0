From: Cong Wang <amwang@redhat.com>
Subject: [Patch iproute2] iptunnel: check SIT_ISATAP flag only for SIT tunnel
Date: Tue,  2 Jul 2013 17:39:28 +0800
Message-ID: <1372757968-21236-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18922 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932250Ab3GBJjk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jul 2013 05:39:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without patch, I got:

	# ./ip/ip tunnel show
	ip_vti0: ioctl 89f4 failed: Invalid argument
	ip_vti0: ip/ip  remote any  local any  ttl inherit  nopmtudisc key 0

this is due to VTI_ISVTI has the same numeric value with SIT_ISATAP,
but only sit tunnel has SIOCGETPRL, therefore it should check for SIT
tunnel first.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 4275f26..43f8585 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -341,7 +341,7 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 	       p->iph.daddr ? format_host(AF_INET, 4, &p->iph.daddr, s1, sizeof(s1))  : "any",
 	       p->iph.saddr ? rt_addr_n2a(AF_INET, 4, &p->iph.saddr, s2, sizeof(s2)) : "any");
 
-	if (p->i_flags & SIT_ISATAP) {
+	if (p->iph.protocol == IPPROTO_IPV6 && (p->i_flags & SIT_ISATAP)) {
 		struct ip_tunnel_prl prl[16];
 		int i;
 		
