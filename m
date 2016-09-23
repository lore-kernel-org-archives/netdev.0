From: =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke-LJ9M9ZcSy1A@public.gmane.org>
Subject: [PATCH 2/3] mac80211: Export fq memory limit information in debugfs
Date: Fri, 23 Sep 2016 21:59:10 +0200
Message-ID: <20160923195911.4572-3-toke@toke.dk>
References: <20160923195911.4572-1-toke@toke.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke-LJ9M9ZcSy1A@public.gmane.org>
To: make-wifi-fast-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160923195911.4572-1-toke-LJ9M9ZcSy1A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add memory limit, usage and overlimit counter to per-PHY 'aqm' debugfs
file.

Signed-off-by: Toke H=C3=B8iland-J=C3=B8rgensen <toke-LJ9M9ZcSy1A@public.gmane.org>
---
 net/mac80211/debugfs.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/mac80211/debugfs.c b/net/mac80211/debugfs.c
index 8ca62b6..f56e2f4 100644
--- a/net/mac80211/debugfs.c
+++ b/net/mac80211/debugfs.c
@@ -89,13 +89,19 @@ static ssize_t aqm_read(struct file *file,
 			"R fq_flows_cnt %u\n"
 			"R fq_backlog %u\n"
 			"R fq_overlimit %u\n"
+			"R fq_overmemory %u\n"
 			"R fq_collisions %u\n"
+			"R fq_memory_usage %u\n"
+			"RW fq_memory_limit %u\n"
 			"RW fq_limit %u\n"
 			"RW fq_quantum %u\n",
 			fq->flows_cnt,
 			fq->backlog,
+			fq->overmemory,
 			fq->overlimit,
 			fq->collisions,
+			fq->memory_usage,
+			fq->memory_limit,
 			fq->limit,
 			fq->quantum);
=20
@@ -128,6 +134,8 @@ static ssize_t aqm_write(struct file *file,
=20
 	if (sscanf(buf, "fq_limit %u", &local->fq.limit) =3D=3D 1)
 		return count;
+	else if (sscanf(buf, "fq_memory_limit %u", &local->fq.memory_limit) =3D=
=3D 1)
+		return count;
 	else if (sscanf(buf, "fq_quantum %u", &local->fq.quantum) =3D=3D 1)
 		return count;
=20
--=20
2.9.3
