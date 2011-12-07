From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: pull request: batman-adv 2011-12-07
Date: Wed,  7 Dec 2011 13:36:40 +0800
Message-ID: <1323236203-24711-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
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

David,

we have to more fixes that we would like to get pulled into net-next/linux-3.2.
Both patches address TT protocol misbehavior. Upon merging these patches into
net-next you'll run into merge conflicts.

Patch1:
++<<<<<<< 
 +              tt_global_entry->common.flags |= TT_CLIENT_PENDING;
 +              send_roam_adv(bat_priv, tt_global_entry->common.addr,
++=======
+               tt_global_entry->flags |= TT_CLIENT_ROAM;
+               tt_global_entry->roam_at = jiffies;
+ 
+               send_roam_adv(bat_priv, tt_global_entry->addr,
++>>>>>>> 

Resolution1:
+======
		tt_global_entry->common.flags |= TT_CLIENT_ROAM;
		tt_global_entry->roam_at = jiffies;
		send_roam_adv(bat_priv, tt_global_entry->common.addr,
+======

Patch2:
++<<<<<<< 
 +                      tt_global_entry->common.flags |= TT_CLIENT_ROAM;
 +                      tt_global_entry->roam_at = jiffies;
 +                      goto out;
++=======
+                       /* if we are deleting a global entry due to a roam
+                        * event, there are two possibilities:
+                        * 1) the client roamed from node A to node B => we mark
+                        *    it with TT_CLIENT_ROAM, we start a timer and we
+                        *    wait for node B to claim it. In case of timeout
+                        *    the entry is purged.
+                        * 2) the client roamed to us => we can directly delete
+                        *    the global entry, since it is useless now. */
+                       tt_local_entry = tt_local_hash_find(bat_priv,
+                                                       tt_global_entry->addr);
+                       if (!tt_local_entry) {
+                               tt_global_entry->flags |= TT_CLIENT_ROAM;
+                               tt_global_entry->roam_at = jiffies;
+                               goto out;
+                       }
++>>>>>>>

Resolution2:
+======
			 /* if we are deleting a global entry due to a roam
			 * event, there are two possibilities:
			 * 1) the client roamed from node A to node B => we mark
			 *    it with TT_CLIENT_ROAM, we start a timer and we
			 *    wait for node B to claim it. In case of timeout
			 *    the entry is purged.
			 * 2) the client roamed to us => we can directly delete
			 *    the global entry, since it is useless now. */
			tt_local_entry = tt_local_hash_find(bat_priv,
						tt_global_entry->common.addr);
			if (!tt_local_entry) {
				tt_global_entry->common.flags |= TT_CLIENT_ROAM;
				tt_global_entry->roam_at = jiffies;
				goto out;
			}
+======

Let me know if you have any further question.

Thanks,
Marek

The following changes since commit 1ea6b8f48918282bdca0b32a34095504ee65bab5:

  Linux 3.2-rc1 (2011-11-07 16:16:02 -0800)

are available in the git repository at:
  git://git.open-mesh.org/linux-merge.git batman-adv/maint

Antonio Quartulli (2):
      batman-adv: in case of roaming mark the client with TT_CLIENT_ROAM
      batman-adv: delete global entry in case of roaming

 net/batman-adv/translation-table.c |   27 ++++++++++++++++++++++-----
 1 files changed, 22 insertions(+), 5 deletions(-)
