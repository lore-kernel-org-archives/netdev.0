From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 3/5] net/mac80211/debugfs.c: use kstrtoul, etc
Date: Sun,  6 Nov 2011 14:26:48 +0100
Message-ID: <1320586010-21931-4-git-send-email-julia@diku.dk>
References: <1320586010-21931-1-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320586010-21931-1-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Use kstrtoul, etc instead of the now deprecated strict_strtoul, etc.

A semantic patch rule for the kstrtoul case is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression a,b;
{int,long} *c;
@@

-strict_strtoul
+kstrtoul
 (a,b,c)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/mac80211/debugfs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -u -p a/net/mac80211/debugfs.c b/net/mac80211/debugfs.c
--- a/net/mac80211/debugfs.c
+++ b/net/mac80211/debugfs.c
@@ -190,7 +190,7 @@ static ssize_t uapsd_max_sp_len_write(st
 		return -EFAULT;
 	buf[len] = '\0';
 
-	ret = strict_strtoul(buf, 0, &val);
+	ret = kstrtoul(buf, 0, &val);
 
 	if (ret)
 		return -EINVAL;
