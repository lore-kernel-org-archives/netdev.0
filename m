From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH][BLUETOOTH] remove now unneeded references to sk_protinfo
Date: Sat, 19 Mar 2005 15:06:03 -0300
Message-ID: <20050319180603.GB29585@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="RnlQjJ0d97Da+TV1"
Cc: netdev@oss.sgi.com
To: davem@davemloft.net, Marcel Holtmann <marcel@holtmann.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi David, Marcel,

	Please apply this patch, now only the HAM radio protocols
and af_wanpipe uses sk_protinfo.

	Available at:

bk://kernel.bkbits.net/acme/connection_sock-2.6

- Arnaldo

--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="bluetooth_sk_protinfo_removal.patch"

===================================================================


ChangeSet@1.2289, 2005-03-19 14:41:18-03:00, acme@toy.ghostprotocols.net
  [BLUETOOTH] remove now unneeded references to sk_protinfo
  
  Now that sk_protinfo is not used anymore for storing private proto
  state, we can safely remove the code in the sock destruct path to
  kfree it.
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
  Signed-off-by: David S. Miller <davem@davemloft.net>


 l2cap.c       |    3 ---
 rfcomm/sock.c |    3 ---
 sco.c         |    3 ---
 3 files changed, 9 deletions(-)


diff -Nru a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
--- a/net/bluetooth/l2cap.c	2005-03-19 15:01:55 -03:00
+++ b/net/bluetooth/l2cap.c	2005-03-19 15:01:55 -03:00
@@ -264,9 +264,6 @@
 
 	skb_queue_purge(&sk->sk_receive_queue);
 	skb_queue_purge(&sk->sk_write_queue);
-
-	if (sk->sk_protinfo)
-		kfree(sk->sk_protinfo);
 }
 
 static void l2cap_sock_cleanup_listen(struct sock *parent)
diff -Nru a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
--- a/net/bluetooth/rfcomm/sock.c	2005-03-19 15:01:55 -03:00
+++ b/net/bluetooth/rfcomm/sock.c	2005-03-19 15:01:55 -03:00
@@ -196,9 +196,6 @@
 	rfcomm_dlc_unlock(d);
 
 	rfcomm_dlc_put(d);
-
-	if (sk->sk_protinfo)
-		kfree(sk->sk_protinfo);
 }
 
 static void rfcomm_sock_cleanup_listen(struct sock *parent)
diff -Nru a/net/bluetooth/sco.c b/net/bluetooth/sco.c
--- a/net/bluetooth/sco.c	2005-03-19 15:01:55 -03:00
+++ b/net/bluetooth/sco.c	2005-03-19 15:01:55 -03:00
@@ -334,9 +334,6 @@
 
 	skb_queue_purge(&sk->sk_receive_queue);
 	skb_queue_purge(&sk->sk_write_queue);
-
-	if (sk->sk_protinfo)
-		kfree(sk->sk_protinfo);
 }
 
 static void sco_sock_cleanup_listen(struct sock *parent)


--RnlQjJ0d97Da+TV1--
