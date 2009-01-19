From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/03: x_tables: fix match/target revision lookup
Date: Mon, 19 Jan 2009 15:19:36 +0100 (MET)
Message-ID: <20090119141936.3312.11001.sendpatchset@x2.localnet>
References: <20090119141934.3312.15532.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net
To: stable@kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090119141934.3312.15532.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 2a95ec76ab10585ce54a64300b9bf9b76f10269d
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jan 19 15:10:50 2009 +0100

    netfilter: x_tables: fix match/target revision lookup
    
    Upstream commit 656caff:
    
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
 
