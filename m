From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/09: x_tables: fix match/target revision lookup
Date: Mon, 12 Jan 2009 11:06:04 +0100 (MET)
Message-ID: <20090112100604.9280.34217.sendpatchset@x2.localnet>
References: <20090112100559.9280.23431.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60698 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600AbZALKGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 05:06:06 -0500
In-Reply-To: <20090112100559.9280.23431.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 8005c00a9f53d2a3da11fa1083ae00d06f22f500
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jan 12 08:47:25 2009 +0100

    netfilter: x_tables: fix match/target revision lookup
    
    Commit 55b69e91 (netfilter: implement NFPROTO_UNSPEC as a wildcard
    for extensions) broke revision probing for matches and targets that
    are registered with NFPROTO_UNSPEC.
    
    Fix by continuing the search on the NFPROTO_UNSPEC list if nothing
    is found on the af-specific lists.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 89837a4..bfbf521 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -273,6 +273,10 @@ static int match_revfn(u8 af, const char *name, u8 revision, int *bestp)
 				have_rev = 1;
 		}
 	}
+
+	if (af != NFPROTO_UNSPEC && !have_rev)
+		return match_revfn(NFPROTO_UNSPEC, name, revision, bestp);
+
 	return have_rev;
 }
 
@@ -289,6 +293,10 @@ static int target_revfn(u8 af, const char *name, u8 revision, int *bestp)
 				have_rev = 1;
 		}
 	}
+
+	if (af != NFPROTO_UNSPEC && !have_rev)
+		return target_revfn(NFPROTO_UNSPEC, name, revision, bestp);
+
 	return have_rev;
 }
 
