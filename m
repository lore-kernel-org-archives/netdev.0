From: domen@coderock.org
Subject: [patch 1/1] net/ltpc: replace schedule_timeout() with ssleep()/msleep()
Date: Sat, 05 Mar 2005 16:47:25 +0100
Message-ID: <20050305154726.66FDA1EE1E@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com,
        janitor@sternwelten.at
To: acme@conectiva.com.br
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Use ssleep() / msleep() [as appropriate]
instead of schedule_timeout() to guarantee the task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Acked-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/appletalk/ltpc.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff -puN drivers/net/appletalk/ltpc.c~msleep+ssleep-drivers_net_appletalk_ltpc drivers/net/appletalk/ltpc.c
--- kj/drivers/net/appletalk/ltpc.c~msleep+ssleep-drivers_net_appletalk_ltpc	2005-03-05 16:09:41.000000000 +0100
+++ kj-domen/drivers/net/appletalk/ltpc.c	2005-03-05 16:09:41.000000000 +0100
@@ -1109,8 +1109,7 @@ struct net_device * __init ltpc_probe(vo
 	inb_p(io+1);
 	inb_p(io+3);
 
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(2*HZ/100);
+	msleep(20);
 
 	inb_p(io+0);
 	inb_p(io+2);
@@ -1120,8 +1119,7 @@ struct net_device * __init ltpc_probe(vo
 	inb_p(io+5); /* enable dma */
 	inb_p(io+6); /* tri-state interrupt line */
 
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(HZ);
+	ssleep(1);
 	
 	/* now, figure out which dma channel we're using, unless it's
 	   already been specified */
_
