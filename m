From: jamal <hadi@cyberus.ca>
Subject: patch: Action repeat
Date: Sat, 30 Apr 2005 12:50:17 -0400
Message-ID: <1114879817.8929.117.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-lz9R0bjWTI1yecHQQQAK"
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-lz9R0bjWTI1yecHQQQAK
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Long standing bug.
Policy to repeat an action never worked.

signed-off-by: J Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

--=-lz9R0bjWTI1yecHQQQAK
Content-Disposition: attachment; filename=repeat_p
Content-Type: text/plain; name=repeat_p; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- a/net/sched/act_api.c	2005/04/30 16:17:16	1.1
+++ b/net/sched/act_api.c	2005/04/30 16:17:44
@@ -171,10 +171,10 @@
 				skb->tc_verd = SET_TC_OK2MUNGE(skb->tc_verd);
 				skb->tc_verd = CLR_TC_MUNGED(skb->tc_verd);
 			}
-			if (ret != TC_ACT_PIPE)
-				goto exec_done;
 			if (ret == TC_ACT_REPEAT)
 				goto repeat;	/* we need a ttl - JHS */
+			if (ret != TC_ACT_PIPE)
+				goto exec_done;
 		}
 		act = a->next;
 	}

--=-lz9R0bjWTI1yecHQQQAK--
