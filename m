From: Isaac Boukris <iboukris@gmail.com>
Subject: [PATCH] iproute2: ss: escape all null bytes in abstract unix domain socket
Date: Sat, 29 Oct 2016 22:20:19 +0300
Message-ID: <1477768820-1295-1-git-send-email-iboukris@gmail.com>
Cc: Isaac Boukris <iboukris@gmail.com>
To: stephen@networkplumber.org, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Abstract unix domain socket may embed null characters,
these should be translated to '@' when printed by ss the
same way the null prefix is currently being translated.

Signed-off-by: Isaac Boukris <iboukris@gmail.com>
---
 misc/ss.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index dd77b81..0e28998 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2895,7 +2895,9 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 		memcpy(name, RTA_DATA(tb[UNIX_DIAG_NAME]), len);
 		name[len] = '\0';
 		if (name[0] == '\0')
-			name[0] = '@';
+			for (int i = 0; i < len; i++)
+				if (name[i] == '\0')
+					name[i] = '@';
 		stat.name = &name[0];
 		memcpy(stat.local.data, &stat.name, sizeof(stat.name));
 	}
-- 
2.7.4
