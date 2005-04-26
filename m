From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 2.6 4/6][SCTP] Fix bug in sctp_init() error handling code.
Date: Tue, 26 Apr 2005 11:32:43 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0504261118350.6387@dyn9047018105.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[SCTP] Fix bug in sctp_init() error handling code.

Signed-off-by: Neil Horman <nhorman@redhat.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
-------------------------------------------------------------------
diff -Nru a/net/sctp/protocol.c b/net/sctp/protocol.c
--- a/net/sctp/protocol.c	2005-04-21 16:23:29 -07:00
+++ b/net/sctp/protocol.c	2005-04-21 16:23:29 -07:00
@@ -1159,8 +1159,6 @@
 	status = 0;
 out:
 	return status;
-err_add_protocol:
-	proto_unregister(&sctp_prot);
 err_ctl_sock_init:
 	sctp_v6_exit();
 err_v6_init:
@@ -1188,6 +1186,8 @@
 	inet_del_protocol(&sctp_protocol, IPPROTO_SCTP);
 	inet_unregister_protosw(&sctp_seqpacket_protosw);
 	inet_unregister_protosw(&sctp_stream_protosw);
+err_add_protocol:
+	proto_unregister(&sctp_prot);
 	goto out;
 }
