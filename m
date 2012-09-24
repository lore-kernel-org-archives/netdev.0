From: pablo@netfilter.org
Subject: [PATCH 06/16] netfilter: ipset: Fix sparse warnings "incorrect type in assignment"
Date: Mon, 24 Sep 2012 21:19:18 +0200
Message-ID: <1348514369-3272-7-git-send-email-pablo@netfilter.org>
References: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58101 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757887Ab2IXTVB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 15:21:01 -0400
In-Reply-To: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_ip.c        |    4 ++--
 net/netfilter/ipset/ip_set_hash_ipport.c    |   13 +++++++------
 net/netfilter/ipset/ip_set_hash_ipportip.c  |   13 +++++++------
 net/netfilter/ipset/ip_set_hash_ipportnet.c |   21 ++++++++++++---------
 net/netfilter/ipset/ip_set_hash_net.c       |    4 ++--
 net/netfilter/ipset/ip_set_hash_netiface.c  |    4 ++--
 net/netfilter/ipset/ip_set_hash_netport.c   |   13 +++++++------
 7 files changed, 39 insertions(+), 33 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index a68dbd4..42bccd5 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -114,7 +114,7 @@ nla_put_failure:
 static inline void
 hash_ip4_data_next(struct ip_set_hash *h, const struct hash_ip4_elem *d)
 {
-	h->next.ip = ntohl(d->ip);
+	h->next.ip = d->ip;
 }
 
 static int
@@ -188,7 +188,7 @@ hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	hosts = h->netmask == 32 ? 1 : 2 << (32 - h->netmask - 1);
 
 	if (retried)
-		ip = h->next.ip;
+		ip = ntohl(h->next.ip);
 	for (; !before(ip_to, ip); ip += hosts) {
 		nip = htonl(ip);
 		if (nip == 0)
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index 92722bb..e0ce0dae 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -130,8 +130,8 @@ static inline void
 hash_ipport4_data_next(struct ip_set_hash *h,
 		       const struct hash_ipport4_elem *d)
 {
-	h->next.ip = ntohl(d->ip);
-	h->next.port = ntohs(d->port);
+	h->next.ip = d->ip;
+	h->next.port = d->port;
 }
 
 static int
@@ -231,9 +231,10 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	}
 
 	if (retried)
-		ip = h->next.ip;
+		ip = ntohl(h->next.ip);
 	for (; !before(ip_to, ip); ip++) {
-		p = retried && ip == h->next.ip ? h->next.port : port;
+		p = retried && ip == ntohl(h->next.ip) ? ntohs(h->next.port)
+						       : port;
 		for (; p <= port_to; p++) {
 			data.ip = htonl(ip);
 			data.port = htons(p);
@@ -349,7 +350,7 @@ static inline void
 hash_ipport6_data_next(struct ip_set_hash *h,
 		       const struct hash_ipport6_elem *d)
 {
-	h->next.port = ntohs(d->port);
+	h->next.port = d->port;
 }
 
 static int
@@ -431,7 +432,7 @@ hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 		swap(port, port_to);
 
 	if (retried)
-		port = h->next.port;
+		port = ntohs(h->next.port);
 	for (; port <= port_to; port++) {
 		data.port = htons(port);
 		ret = adtfn(set, &data, timeout, flags);
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 0637ce0..c864bf4 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -133,8 +133,8 @@ static inline void
 hash_ipportip4_data_next(struct ip_set_hash *h,
 			 const struct hash_ipportip4_elem *d)
 {
-	h->next.ip = ntohl(d->ip);
-	h->next.port = ntohs(d->port);
+	h->next.ip = d->ip;
+	h->next.port = d->port;
 }
 
 static int
@@ -239,9 +239,10 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	}
 
 	if (retried)
-		ip = h->next.ip;
+		ip = ntohl(h->next.ip);
 	for (; !before(ip_to, ip); ip++) {
-		p = retried && ip == h->next.ip ? h->next.port : port;
+		p = retried && ip == ntohl(h->next.ip) ? ntohs(h->next.port)
+						       : port;
 		for (; p <= port_to; p++) {
 			data.ip = htonl(ip);
 			data.port = htons(p);
@@ -362,7 +363,7 @@ static inline void
 hash_ipportip6_data_next(struct ip_set_hash *h,
 			 const struct hash_ipportip6_elem *d)
 {
-	h->next.port = ntohs(d->port);
+	h->next.port = d->port;
 }
 
 static int
@@ -449,7 +450,7 @@ hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 		swap(port, port_to);
 
 	if (retried)
-		port = h->next.port;
+		port = ntohs(h->next.port);
 	for (; port <= port_to; port++) {
 		data.port = htons(port);
 		ret = adtfn(set, &data, timeout, flags);
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 1ce21ca..2c704bb 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -173,9 +173,9 @@ static inline void
 hash_ipportnet4_data_next(struct ip_set_hash *h,
 			  const struct hash_ipportnet4_elem *d)
 {
-	h->next.ip = ntohl(d->ip);
-	h->next.port = ntohs(d->port);
-	h->next.ip2 = ntohl(d->ip2);
+	h->next.ip = d->ip;
+	h->next.port = d->port;
+	h->next.ip2 = d->ip2;
 }
 
 static int
@@ -314,14 +314,17 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	}
 
 	if (retried)
-		ip = h->next.ip;
+		ip = ntohl(h->next.ip);
 	for (; !before(ip_to, ip); ip++) {
 		data.ip = htonl(ip);
-		p = retried && ip == h->next.ip ? h->next.port : port;
+		p = retried && ip == ntohl(h->next.ip) ? ntohs(h->next.port)
+						       : port;
 		for (; p <= port_to; p++) {
 			data.port = htons(p);
-			ip2 = retried && ip == h->next.ip && p == h->next.port
-				? h->next.ip2 : ip2_from;
+			ip2 = retried
+			      && ip == ntohl(h->next.ip)
+			      && p == ntohs(h->next.port)
+				? ntohl(h->next.ip2) : ip2_from;
 			while (!after(ip2, ip2_to)) {
 				data.ip2 = htonl(ip2);
 				ip2_last = ip_set_range_to_cidr(ip2, ip2_to,
@@ -486,7 +489,7 @@ static inline void
 hash_ipportnet6_data_next(struct ip_set_hash *h,
 			  const struct hash_ipportnet6_elem *d)
 {
-	h->next.port = ntohs(d->port);
+	h->next.port = d->port;
 }
 
 static int
@@ -598,7 +601,7 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 		swap(port, port_to);
 
 	if (retried)
-		port = h->next.port;
+		port = ntohs(h->next.port);
 	for (; port <= port_to; port++) {
 		data.port = htons(port);
 		ret = adtfn(set, &data, timeout, flags);
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index c57a6a0..d676093 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -152,7 +152,7 @@ static inline void
 hash_net4_data_next(struct ip_set_hash *h,
 		    const struct hash_net4_elem *d)
 {
-	h->next.ip = ntohl(d->ip);
+	h->next.ip = d->ip;
 }
 
 static int
@@ -235,7 +235,7 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 			return -IPSET_ERR_HASH_RANGE;
 	}
 	if (retried)
-		ip = h->next.ip;
+		ip = ntohl(h->next.ip);
 	while (!after(ip, ip_to)) {
 		data.ip = htonl(ip);
 		last = ip_set_range_to_cidr(ip, ip_to, &data.cidr);
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index d5d3607..632693f 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -277,7 +277,7 @@ static inline void
 hash_netiface4_data_next(struct ip_set_hash *h,
 			 const struct hash_netiface4_elem *d)
 {
-	h->next.ip = ntohl(d->ip);
+	h->next.ip = d->ip;
 }
 
 static int
@@ -409,7 +409,7 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 	}
 
 	if (retried)
-		ip = h->next.ip;
+		ip = ntohl(h->next.ip);
 	while (!after(ip, ip_to)) {
 		data.ip = htonl(ip);
 		last = ip_set_range_to_cidr(ip, ip_to, &data.cidr);
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index fc3143a..3ec27fc 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -171,8 +171,8 @@ static inline void
 hash_netport4_data_next(struct ip_set_hash *h,
 			const struct hash_netport4_elem *d)
 {
-	h->next.ip = ntohl(d->ip);
-	h->next.port = ntohs(d->port);
+	h->next.ip = d->ip;
+	h->next.port = d->port;
 }
 
 static int
@@ -289,12 +289,13 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	}
 
 	if (retried)
-		ip = h->next.ip;
+		ip = ntohl(h->next.ip);
 	while (!after(ip, ip_to)) {
 		data.ip = htonl(ip);
 		last = ip_set_range_to_cidr(ip, ip_to, &cidr);
 		data.cidr = cidr - 1;
-		p = retried && ip == h->next.ip ? h->next.port : port;
+		p = retried && ip == ntohl(h->next.ip) ? ntohs(h->next.port)
+						       : port;
 		for (; p <= port_to; p++) {
 			data.port = htons(p);
 			ret = adtfn(set, &data, timeout, flags);
@@ -450,7 +451,7 @@ static inline void
 hash_netport6_data_next(struct ip_set_hash *h,
 			const struct hash_netport6_elem *d)
 {
-	h->next.port = ntohs(d->port);
+	h->next.port = d->port;
 }
 
 static int
@@ -554,7 +555,7 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 		swap(port, port_to);
 
 	if (retried)
-		port = h->next.port;
+		port = ntohs(h->next.port);
 	for (; port <= port_to; port++) {
 		data.port = htons(port);
 		ret = adtfn(set, &data, timeout, flags);
-- 
1.7.10.4
