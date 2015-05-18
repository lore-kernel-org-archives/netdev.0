From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/21] netfilter: ipset: Check for comment netlink attribute length
Date: Mon, 18 May 2015 18:25:14 +0200
Message-ID: <1431966324-4494-12-git-send-email-pablo@netfilter.org>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44034 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932405AbbERQUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 12:20:51 -0400
In-Reply-To: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Popovich <popovich_sergei@mail.ua>

Ensure userspace supplies string not longer than
IPSET_MAX_COMMENT_SIZE.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_bitmap_ip.c       |    3 ++-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c    |    3 ++-
 net/netfilter/ipset/ip_set_bitmap_port.c     |    3 ++-
 net/netfilter/ipset/ip_set_hash_ip.c         |    3 ++-
 net/netfilter/ipset/ip_set_hash_ipmark.c     |    3 ++-
 net/netfilter/ipset/ip_set_hash_ipport.c     |    3 ++-
 net/netfilter/ipset/ip_set_hash_ipportip.c   |    3 ++-
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |    3 ++-
 net/netfilter/ipset/ip_set_hash_mac.c        |    3 ++-
 net/netfilter/ipset/ip_set_hash_net.c        |    3 ++-
 net/netfilter/ipset/ip_set_hash_netiface.c   |    3 ++-
 net/netfilter/ipset/ip_set_hash_netnet.c     |    3 ++-
 net/netfilter/ipset/ip_set_hash_netport.c    |    3 ++-
 net/netfilter/ipset/ip_set_hash_netportnet.c |    3 ++-
 net/netfilter/ipset/ip_set_list_set.c        |    3 ++-
 15 files changed, 30 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index 01b88ba..2fe6de4 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -364,7 +364,8 @@ static struct ip_set_type bitmap_ip_type __read_mostly = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
-		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING,
+					    .len  = IPSET_MAX_COMMENT_SIZE },
 		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
 		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 46868b3..eb18856 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -401,7 +401,8 @@ static struct ip_set_type bitmap_ipmac_type = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
-		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING,
+					    .len  = IPSET_MAX_COMMENT_SIZE },
 		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
 		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index 005dd36..898edb6 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -294,7 +294,8 @@ static struct ip_set_type bitmap_port_type = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
-		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING,
+					    .len  = IPSET_MAX_COMMENT_SIZE },
 		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
 		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index e90a82a..ee7a72b 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -304,7 +304,8 @@ static struct ip_set_type hash_ip_type __read_mostly = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
-		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING,
+					    .len  = IPSET_MAX_COMMENT_SIZE },
 		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
 		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
diff --git a/net/netfilter/ipset/ip_set_hash_ipmark.c b/net/netfilter/ipset/ip_set_hash_ipmark.c
index 8584284..6ac7073 100644
--- a/net/netfilter/ipset/ip_set_hash_ipmark.c
+++ b/net/netfilter/ipset/ip_set_hash_ipmark.c
@@ -310,7 +310,8 @@ static struct ip_set_type hash_ipmark_type __read_mostly = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
-		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING,
+					    .len  = IPSET_MAX_COMMENT_SIZE },
 		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
 		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index 73e4d86..a3117d4e 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -373,7 +373,8 @@ static struct ip_set_type hash_ipport_type __read_mostly = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
-		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING,
+					    .len  = IPSET_MAX_COMMENT_SIZE },
 		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
 		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 4f8e584..89615f1 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -385,7 +385,8 @@ static struct ip_set_type hash_ipportip_type __read_mostly = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
-		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING,
+					    .len  = IPSET_MAX_COMMENT_SIZE },
 		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
 		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 4363a18..6ba7a7e 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -544,7 +544,8 @@ static struct ip_set_type hash_ipportnet_type __read_mostly = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
-		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING,
+					    .len  = IPSET_MAX_COMMENT_SIZE },
 		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
 		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
diff --git a/net/netfilter/ipset/ip_set_hash_mac.c b/net/netfilter/ipset/ip_set_hash_mac.c
index 3614683..1f8668d 100644
--- a/net/netfilter/ipset/ip_set_hash_mac.c
+++ b/net/netfilter/ipset/ip_set_hash_mac.c
@@ -153,7 +153,8 @@ static struct ip_set_type hash_mac_type __read_mostly = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
-		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING,
+					    .len  = IPSET_MAX_COMMENT_SIZE },
 		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
 		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 2feaed3..2e63dad 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -386,7 +386,8 @@ static struct ip_set_type hash_net_type __read_mostly = {
 		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
-		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING,
+					    .len  = IPSET_MAX_COMMENT_SIZE },
 		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
 		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 322b773..07920b6 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -616,7 +616,8 @@ static struct ip_set_type hash_netiface_type __read_mostly = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
-		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING,
+					    .len  = IPSET_MAX_COMMENT_SIZE },
 		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
 		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
index f065024..8470474 100644
--- a/net/netfilter/ipset/ip_set_hash_netnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -479,7 +479,8 @@ static struct ip_set_type hash_netnet_type __read_mostly = {
 		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
-		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING,
+					    .len  = IPSET_MAX_COMMENT_SIZE },
 		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
 		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index bd45465..8273819 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -492,7 +492,8 @@ static struct ip_set_type hash_netport_type __read_mostly = {
 		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
-		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING,
+					    .len  = IPSET_MAX_COMMENT_SIZE },
 		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
 		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
index dd64ba9..1451a8a 100644
--- a/net/netfilter/ipset/ip_set_hash_netportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
@@ -580,7 +580,8 @@ static struct ip_set_type hash_netportnet_type __read_mostly = {
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
-		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING,
+					    .len  = IPSET_MAX_COMMENT_SIZE },
 		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
 		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index f8f6828..5bd3b1e 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -678,7 +678,8 @@ static struct ip_set_type list_set_type __read_mostly = {
 		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
 		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
-		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING },
+		[IPSET_ATTR_COMMENT]	= { .type = NLA_NUL_STRING,
+					    .len  = IPSET_MAX_COMMENT_SIZE },
 		[IPSET_ATTR_SKBMARK]	= { .type = NLA_U64 },
 		[IPSET_ATTR_SKBPRIO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_SKBQUEUE]	= { .type = NLA_U16 },
-- 
1.7.10.4
