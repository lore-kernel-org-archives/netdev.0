From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH Linux-2.6.8-rc1] prism54 Fix reference to
	uninitialized pointer
Date: Thu, 15 Jul 2004 15:52:02 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200407151552.03289.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_Dwo9ABdo1SDLJ2W"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_Dwo9ABdo1SDLJ2W
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-07-15 Margit Schubert-While <margitsw@t-online.de>

* oid_mgt.c is calling islpci_mgt_transaction passing the address
  of a pointer to the management frame. This is not being
  initialized by the caller. The callee only updates this
  pointer when successful. When not, boom.

* Being ultracautious again, not only initialize in the caller,
  also null out the pointer unconditionally in the callee.


Margit









--Boundary-00=_Dwo9ABdo1SDLJ2W
Content-Type: text/x-diff;
  charset="us-ascii";
  name="mgtframeptr.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="mgtframeptr.patch"

diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/islpci_mgt.c linux-2.6.8-03/drivers/net/wireless/prism54/islpci_mgt.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/islpci_mgt.c	2004-06-25 19:48:40.000000000 +0200
+++ linux-2.6.8-03/drivers/net/wireless/prism54/islpci_mgt.c	2004-07-15 15:17:21.000000000 +0200
@@ -458,6 +458,8 @@
 	int err;
 	DEFINE_WAIT(wait);
 
+	*recvframe = NULL;
+
 	if (down_interruptible(&priv->mgmt_sem))
 		return -ERESTARTSYS;
 
diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/oid_mgt.c linux-2.6.8-03/drivers/net/wireless/prism54/oid_mgt.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/oid_mgt.c	2004-07-14 21:55:11.000000000 +0200
+++ linux-2.6.8-03/drivers/net/wireless/prism54/oid_mgt.c	2004-07-15 15:13:53.000000000 +0200
@@ -408,7 +408,7 @@
 mgt_set_request(islpci_private *priv, enum oid_num_t n, int extra, void *data)
 {
 	int ret = 0;
-	struct islpci_mgmtframe *response;
+	struct islpci_mgmtframe *response = NULL;
 	int response_op = PIMFOR_OP_ERROR;
 	int dlen;
 	void *cache, *_data = data;
@@ -620,7 +620,7 @@
 static int
 mgt_update_addr(islpci_private *priv)
 {
-	struct islpci_mgmtframe *res;
+	struct islpci_mgmtframe *res = NULL;
 	int ret;
 
 	ret = islpci_mgt_transaction(priv->ndev, PIMFOR_OP_GET,

--Boundary-00=_Dwo9ABdo1SDLJ2W
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_Dwo9ABdo1SDLJ2W--
