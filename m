From: ondrej.lysonek-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org
Subject: [PATCH] mac80211: Use setup_timer instead of init_timer
Date: Thu,  9 Mar 2017 10:34:36 +0100
Message-ID: <20170309093436.25227-1-ondrej.lysonek@seznam.cz>
References: <1488803104.5761.6.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Ond=C5=99ej=20Lyson=C4=9Bk?= <ondrej.lysonek-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org>,
        Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1488803104.5761.6.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ondřej Lysoněk <ondrej.lysonek-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org>

Use setup_timer() and setup_deferrable_timer() to set the data and
function timer fields. It makes the code cleaner and will allow for
easier change of the timer struct internals.

Signed-off-by: Ondřej Lysoněk <ondrej.lysonek-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org>
Cc: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
---
 net/mac80211/mesh_pathtbl.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index f0e6175..64c6174 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -397,11 +397,10 @@ struct mesh_path *mesh_path_new(struct ieee80211_sub_if_data *sdata,
 	new_mpath->sdata = sdata;
 	new_mpath->flags = 0;
 	skb_queue_head_init(&new_mpath->frame_queue);
-	new_mpath->timer.data = (unsigned long) new_mpath;
-	new_mpath->timer.function = mesh_path_timer;
 	new_mpath->exp_time = jiffies;
 	spin_lock_init(&new_mpath->state_lock);
-	init_timer(&new_mpath->timer);
+	setup_timer(&new_mpath->timer, mesh_path_timer,
+		    (unsigned long) new_mpath);
 
 	return new_mpath;
 }
-- 
2.9.3
