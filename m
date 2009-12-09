From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 11/12] net/mac80211: Correct size given to memset
Date: Wed, 9 Dec 2009 20:25:59 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0912092025240.1870@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757429AbZLIT0B@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Memset should be given the size of the structure, not the size of the pointer.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
type T;
T *x;
expression E;
@@

memset(x, E, sizeof(
+ *
 x))
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/mac80211/mesh.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -u -p a/net/mac80211/mesh.c b/Net/mac80211/mesh.c
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -427,7 +427,7 @@ int ieee80211_new_mesh_header(struct iee
 		char *addr5, char *addr6)
 {
 	int aelen = 0;
-	memset(meshhdr, 0, sizeof(meshhdr));
+	memset(meshhdr, 0, sizeof(*meshhdr));
 	meshhdr->ttl = sdata->u.mesh.mshcfg.dot11MeshTTL;
 	put_unaligned(cpu_to_le32(sdata->u.mesh.mesh_seqnum), &meshhdr->seqnum);
 	sdata->u.mesh.mesh_seqnum++;
