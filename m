From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 2/8] batman-adv: Make gateway_get_selected
	type safe
Date: Sun, 17 Apr 2011 21:30:12 +0200
Message-ID: <1303068618-27928-3-git-send-email-sven@narfation.org>
References: <1303068618-27928-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1303068618-27928-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Linus L=C3=BCssing <linus.luessing-S0/GAf8tV78@public.gmane.org>

Make the return value explicit instead of (void *).

Signed-off-by: Linus L=C3=BCssing <linus.luessing-S0/GAf8tV78@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/gateway_client.c |    2 +-
 net/batman-adv/gateway_client.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_cli=
ent.c
index 3cc4355..27b87ad 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -42,7 +42,7 @@ static void gw_node_free_ref(struct gw_node *gw_node)
 		call_rcu(&gw_node->rcu, gw_node_free_rcu);
 }
=20
-void *gw_get_selected(struct bat_priv *bat_priv)
+struct orig_node *gw_get_selected(struct bat_priv *bat_priv)
 {
 	struct gw_node *curr_gateway_tmp;
 	struct orig_node *orig_node =3D NULL;
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_cli=
ent.h
index 2aa4391..97c31d1 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -24,7 +24,7 @@
=20
 void gw_deselect(struct bat_priv *bat_priv);
 void gw_election(struct bat_priv *bat_priv);
-void *gw_get_selected(struct bat_priv *bat_priv);
+struct orig_node *gw_get_selected(struct bat_priv *bat_priv);
 void gw_check_election(struct bat_priv *bat_priv, struct orig_node *orig=
_node);
 void gw_node_update(struct bat_priv *bat_priv,
 		    struct orig_node *orig_node, uint8_t new_gwflags);
--=20
1.7.4.4
