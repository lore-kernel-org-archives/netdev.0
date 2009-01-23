From: Greg KH <gregkh@suse.de>
Subject: [patch 28/46] netfilter: x_tables: fix match/target revision lookup
Date: Thu, 22 Jan 2009 17:12:31 -0800
Message-ID: <20090123011231.GC19756@kroah.com>
References: <20090123010651.683741823@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Domenico Andreoli <cavokz@gmail.com>, Willy Tarreau <w@1wt.eu>,
	Rodrigo Rubira Branco <rbranco@la.checkpoint.com>,
	Jake Edge <jake@lwn.net>, Eugene Teo <eteo@redhat.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	davem@davemloft.net
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename="netfilter-x_tables-fix-match-target-revision-lookup.patch"
In-Reply-To: <20090123011110.GA19756@kroah.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2.6.28-stable review patch.  If anyone has any objections, please let us know.

------------------

From: Patrick McHardy <kaber@trash.net>

Upstream commit 656caff:

Commit 55b69e91 (netfilter: implement NFPROTO_UNSPEC as a wildcard
for extensions) broke revision probing for matches and targets that
are registered with NFPROTO_UNSPEC.

Fix by continuing the search on the NFPROTO_UNSPEC list if nothing
is found on the af-specific lists.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/netfilter/x_tables.c |    8 ++++++++
 1 file changed, 8 insertions(+)

--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -273,6 +273,10 @@ static int match_revfn(u8 af, const char
 				have_rev = 1;
 		}
 	}
+
+	if (af != NFPROTO_UNSPEC && !have_rev)
+		return match_revfn(NFPROTO_UNSPEC, name, revision, bestp);
+
 	return have_rev;
 }
 
@@ -289,6 +293,10 @@ static int target_revfn(u8 af, const cha
 				have_rev = 1;
 		}
 	}
+
+	if (af != NFPROTO_UNSPEC && !have_rev)
+		return target_revfn(NFPROTO_UNSPEC, name, revision, bestp);
+
 	return have_rev;
 }
 

