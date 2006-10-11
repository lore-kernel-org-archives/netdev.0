From: paul.moore@hp.com
Subject: [PATCH 1/3] NetLabel: only deref the CIPSOv4 standard map fields when using standard mapping
Date: Wed, 11 Oct 2006 19:10:47 -0400
Message-ID: <20061011231356.095058000@hp.com>
References: <20061011231046.825517000@hp.com>
Cc: jmorris@namei.org, eparis@redhat.com,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:39876 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S1161022AbWJKXN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 19:13:59 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-cipso_mtypefix
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

Fix several places in the CIPSO code where it was dereferencing fields which
did not have valid pointers by moving those pointer dereferences into code
blocks where the pointers are valid.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/ipv4/cipso_ipv4.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

Index: net-2.6_bugfix_2/net/ipv4/cipso_ipv4.c
===================================================================
--- net-2.6_bugfix_2.orig/net/ipv4/cipso_ipv4.c
+++ net-2.6_bugfix_2/net/ipv4/cipso_ipv4.c
@@ -773,13 +773,15 @@ static int cipso_v4_map_cat_rbm_valid(co
 {
 	int cat = -1;
 	u32 bitmap_len_bits = bitmap_len * 8;
-	u32 cipso_cat_size = doi_def->map.std->cat.cipso_size;
-	u32 *cipso_array = doi_def->map.std->cat.cipso;
+	u32 cipso_cat_size;
+	u32 *cipso_array;
 
 	switch (doi_def->type) {
 	case CIPSO_V4_MAP_PASS:
 		return 0;
 	case CIPSO_V4_MAP_STD:
+		cipso_cat_size = doi_def->map.std->cat.cipso_size;
+		cipso_array = doi_def->map.std->cat.cipso;
 		for (;;) {
 			cat = cipso_v4_bitmap_walk(bitmap,
 						   bitmap_len_bits,
@@ -825,8 +827,8 @@ static int cipso_v4_map_cat_rbm_hton(con
 	u32 net_spot_max = 0;
 	u32 host_clen_bits = host_cat_len * 8;
 	u32 net_clen_bits = net_cat_len * 8;
-	u32 host_cat_size = doi_def->map.std->cat.local_size;
-	u32 *host_cat_array = doi_def->map.std->cat.local;
+	u32 host_cat_size;
+	u32 *host_cat_array;
 
 	switch (doi_def->type) {
 	case CIPSO_V4_MAP_PASS:
@@ -838,6 +840,8 @@ static int cipso_v4_map_cat_rbm_hton(con
 		memcpy(net_cat, host_cat, net_spot_max);
 		return net_spot_max;
 	case CIPSO_V4_MAP_STD:
+		host_cat_size = doi_def->map.std->cat.local_size;
+		host_cat_array = doi_def->map.std->cat.local;
 		for (;;) {
 			host_spot = cipso_v4_bitmap_walk(host_cat,
 							 host_clen_bits,
@@ -893,8 +897,8 @@ static int cipso_v4_map_cat_rbm_ntoh(con
 	int net_spot = -1;
 	u32 net_clen_bits = net_cat_len * 8;
 	u32 host_clen_bits = host_cat_len * 8;
-	u32 net_cat_size = doi_def->map.std->cat.cipso_size;
-	u32 *net_cat_array = doi_def->map.std->cat.cipso;
+	u32 net_cat_size;
+	u32 *net_cat_array;
 
 	switch (doi_def->type) {
 	case CIPSO_V4_MAP_PASS:
@@ -903,6 +907,8 @@ static int cipso_v4_map_cat_rbm_ntoh(con
 		memcpy(host_cat, net_cat, net_cat_len);
 		return net_cat_len;
 	case CIPSO_V4_MAP_STD:
+		net_cat_size = doi_def->map.std->cat.cipso_size;
+		net_cat_array = doi_def->map.std->cat.cipso;
 		for (;;) {
 			net_spot = cipso_v4_bitmap_walk(net_cat,
 							net_clen_bits,

--
paul moore
linux security @ hp
