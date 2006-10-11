From: paul.moore@hp.com
Subject: [PATCH 3/3] NetLabel: the CIPSOv4 passthrough mapping does not pass categories correctly
Date: Wed, 11 Oct 2006 19:10:49 -0400
Message-ID: <20061011231357.321273000@hp.com>
References: <20061011231046.825517000@hp.com>
Cc: jmorris@namei.org, eparis@redhat.com,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:59338 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1161276AbWJKXN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 19:13:59 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-cipso_passfix
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

The CIPSO passthrough mapping had a problem when sending categories which
would cause no or incorrect categories to be sent on the wire with a packet.
This patch fixes the problem which was a simple off-by-one bug.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/ipv4/cipso_ipv4.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Index: net-2.6_bugfix_2/net/ipv4/cipso_ipv4.c
===================================================================
--- net-2.6_bugfix_2.orig/net/ipv4/cipso_ipv4.c
+++ net-2.6_bugfix_2/net/ipv4/cipso_ipv4.c
@@ -832,8 +832,8 @@ static int cipso_v4_map_cat_rbm_hton(con
 
 	switch (doi_def->type) {
 	case CIPSO_V4_MAP_PASS:
-		net_spot_max = host_cat_len - 1;
-		while (net_spot_max > 0 && host_cat[net_spot_max] == 0)
+		net_spot_max = host_cat_len;
+		while (net_spot_max > 0 && host_cat[net_spot_max - 1] == 0)
 			net_spot_max--;
 		if (net_spot_max > net_cat_len)
 			return -EINVAL;

--
paul moore
linux security @ hp
