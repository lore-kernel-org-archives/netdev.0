From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/3] [PKT_SCHED]: Properly return when no backward compatibility action statistics are to be dumped
Date: Sat, 2 Apr 2005 01:27:30 +0200
Message-ID: <20050401232730.GK3086@postel.suug.ch>
References: <20050401232654.GJ3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050401232654.GJ3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/04/01 14:05:21+02:00 tgraf@suug.ch 
#   [PKT_SCHED]: Properly return when no backward compatibility action statistics are to be dumped
#   
#   Fixes a stupid bug introcuded in my "Fix action statistics dumping in
#   compatibility mode" patch, no clue why it actually worked without this fix.
#   
#   Signed-off-by: Thomas Graf <tgraf@suug.ch>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/sched/act_api.c
#   2005/04/01 14:05:09+02:00 tgraf@suug.ch +2 -0
#   [PKT_SCHED]: Properly return when no backward compatibility action statistics are to be dumped
# 
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2005-04-02 01:18:40 +02:00
+++ b/net/sched/act_api.c	2005-04-02 01:18:40 +02:00
@@ -397,6 +397,8 @@
 		if (a->type == TCA_OLD_COMPAT)
 			err = gnet_stats_start_copy_compat(skb, 0,
 				TCA_STATS, TCA_XSTATS, h->stats_lock, &d);
+		else
+			return 0;
 	} else
 		err = gnet_stats_start_copy(skb, TCA_ACT_STATS,
 			h->stats_lock, &d);
