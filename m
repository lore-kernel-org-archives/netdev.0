From: Isaac Boukris <iboukris@gmail.com>
Subject: [PATCH v2] unix: escape all null bytes in abstract unix domain socket
Date: Tue,  1 Nov 2016 02:41:35 +0200
Message-ID: <1477960895-1062-1-git-send-email-iboukris@gmail.com>
Cc: Isaac Boukris <iboukris@gmail.com>
To: davem@davemloft.net, stephen@networkplumber.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Abstract unix domain socket may embed null characters,
these should be translated to '@' when printed out to
proc the same way the null prefix is currently being
translated.

This helps for tools such as netstat, lsof and the proc
based implementation in ss to show all the significant
bytes of the name (instead of getting cut at the first
null occurrence).

Signed-off-by: Isaac Boukris <iboukris@gmail.com>
---
 net/unix/af_unix.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 145082e..5d1c14a 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2812,7 +2812,8 @@ static int unix_seq_show(struct seq_file *seq, void *v)
 				i++;
 			}
 			for ( ; i < len; i++)
-				seq_putc(seq, u->addr->name->sun_path[i]);
+				seq_putc(seq, u->addr->name->sun_path[i] ?:
+					 '@');
 		}
 		unix_state_unlock(s);
 		seq_putc(seq, '\n');
-- 
2.7.4
