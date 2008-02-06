From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.25] cxgb3: Handle ARP completions that mark
	neighbors stale.
Date: Wed, 06 Feb 2008 12:05:19 -0600
Message-ID: <20080206180519.4680.34741.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: jeff@garzik.org,divy@chelsio.com
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


cxgb3: Handle ARP completions that mark neighbors stale.

When ARP completes due to a request rather than a reply the neighbor is
marked NUD_STALE instead of reachable (see arp_process()).  The handler
for the resulting netevent needs to check also for NUD_STALE.

Failure to use the arp entry can cause RDMA connection failures.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/net/cxgb3/l2t.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/l2t.c b/drivers/net/cxgb3/l2t.c
index d660af7..d80bbdb 100644
--- a/drivers/net/cxgb3/l2t.c
+++ b/drivers/net/cxgb3/l2t.c
@@ -404,7 +404,7 @@ found:
 			if (neigh->nud_state & NUD_FAILED) {
 				arpq =3D e->arpq_head;
 				e->arpq_head =3D e->arpq_tail =3D NULL;
-			} else if (neigh_is_connected(neigh))
+			} else if (neigh->nud_state & (NUD_CONNECTED|NUD_STALE))
 				setup_l2e_send_pending(dev, NULL, e);
 		} else {
 			e->state =3D neigh_is_connected(neigh) ?
