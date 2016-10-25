From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [net-next] net: ip, diag: include net/inet_sock.h
Date: Tue, 25 Oct 2016 17:53:22 +0200
Message-ID: <20161025155339.9892-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Cyrill Gorcunov <gorcunov@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The newly added raw_diag.c fails to build in some configurations
unless we include this header:

In file included from net/ipv4/raw_diag.c:6:0:
include/net/raw.h:71:21: error: field 'inet' has incomplete type
net/ipv4/raw_diag.c: In function 'raw_diag_dump':
net/ipv4/raw_diag.c:166:29: error: implicit declaration of function 'inet_sk'

Fixes: 432490f9d455 ("net: ip, diag -- Add diag interface for raw sockets")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/ipv4/raw_diag.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/raw_diag.c b/net/ipv4/raw_diag.c
index ef3bea061b75..be930908bcf9 100644
--- a/net/ipv4/raw_diag.c
+++ b/net/ipv4/raw_diag.c
@@ -3,6 +3,7 @@
 #include <linux/inet_diag.h>
 #include <linux/sock_diag.h>
 
+#include <net/inet_sock.h>
 #include <net/raw.h>
 #include <net/rawv6.h>
 
-- 
2.9.0
