From: Abhijit Pawar <abhi.c.pawar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/2] net: remove obsolete simple_strto<foo>
Date: Tue, 11 Dec 2012 11:00:52 +0530
Message-ID: <1355203852-12749-1-git-send-email-abhi.c.pawar@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Abhijit Pawar <abhi.c.pawar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch removes the redundant occurences of simple_strto<foo>

Signed-off-by: Abhijit Pawar <abhi.c.pawar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/core/netpoll.c                |    1 -
 net/mac80211/debugfs_sta.c        |    1 -
 net/netfilter/nf_conntrack_core.c |    1 -
 3 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 12c129f..3151acf 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -706,7 +706,6 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 		*delim = 0;
 		if (*cur == ' ' || *cur == '\t')
 			np_info(np, "warning: whitespace is not allowed\n");
-		np->remote_port = simple_strtol(cur, NULL, 10);
 		if (kstrtou16(cur, 10, &np->remote_port))
 			goto parse_failed;
 		cur = delim;
diff --git a/net/mac80211/debugfs_sta.c b/net/mac80211/debugfs_sta.c
index 0dedb4b..6fb1168 100644
--- a/net/mac80211/debugfs_sta.c
+++ b/net/mac80211/debugfs_sta.c
@@ -220,7 +220,6 @@ static ssize_t sta_agg_status_write(struct file *file, const char __user *userbu
 	} else
 		return -EINVAL;
 
-	tid = simple_strtoul(buf, NULL, 0);
 	ret = kstrtoul(buf, 0, &tid);
 	if (ret)
 		return ret;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 37d9e62..08cdc71 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1422,7 +1422,6 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	if (!nf_conntrack_htable_size)
 		return param_set_uint(val, kp);
 
-	hashsize = simple_strtoul(val, NULL, 0);
 	rc = kstrtouint(val, 0, &hashsize);
 	if (rc)
 		return rc;
-- 
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
