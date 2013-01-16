From: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
Subject: [PATCH 182/222] batman-adv: fix random jitter calculation
Date: Wed, 16 Jan 2013 13:56:22 -0200
Message-ID: <1358351822-7675-183-git-send-email-herton.krzesinski@canonical.com>
References: <1358351822-7675-1-git-send-email-herton.krzesinski@canonical.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Antonio Quartulli <ordex@autistici.org>,
	b.a.t.m.a.n@lists.open-mesh.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	kernel-team@lists.ubuntu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358351822-7675-1-git-send-email-herton.krzesinski@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3.5.7.3 -stable review patch.  If anyone has any objections, please let me know.

------------------

From: Akinobu Mita <akinobu.mita@gmail.com>

commit 143cdd8f33909ff5a153e3f02048738c5964ba26 upstream.

batadv_iv_ogm_emit_send_time() attempts to calculates a random integer
in the range of 'orig_interval +- BATADV_JITTER' by the below lines.

        msecs = atomic_read(&bat_priv->orig_interval) - BATADV_JITTER;
        msecs += (random32() % 2 * BATADV_JITTER);

But it actually gets 'orig_interval' or 'orig_interval - BATADV_JITTER'
because '%' and '*' have same precedence and associativity is
left-to-right.

This adds the parentheses at the appropriate position so that it matches
original intension.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Acked-by: Antonio Quartulli <ordex@autistici.org>
Cc: Marek Lindner <lindner_marek@yahoo.de>
Cc: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Cc: Antonio Quartulli <ordex@autistici.org>
Cc: b.a.t.m.a.n@lists.open-mesh.org
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
---
 net/batman-adv/bat_iv_ogm.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index dc53798..bcf3760 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -117,7 +117,7 @@ static unsigned long bat_iv_ogm_emit_send_time(const struct bat_priv *bat_priv)
 {
 	return jiffies + msecs_to_jiffies(
 		   atomic_read(&bat_priv->orig_interval) -
-		   JITTER + (random32() % 2*JITTER));
+		   JITTER + (random32() % (2*JITTER)));
 }
 
 /* when do we schedule a ogm packet to be sent */
-- 
1.7.9.5
