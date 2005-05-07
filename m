From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1/1][ATM]: net/atm/ioctl.c: autoload pppoatm and br2684
Date: Sat, 07 May 2005 13:15:54 -0400
Message-ID: <200505071715.j47HFrbp016006@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com, Roman Kagan <rkagan@mail.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/05/07 09:15:32-04:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: net/atm/ioctl.c: autoload pppoatm and br2684
#   
#   Signed-off-by: Roman Kagan <rkagan@mail.ru>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/ioctl.c
#   2005/05/07 09:15:12-04:00 chas@relax.cmf.nrl.navy.mil +26 -8
#   [ATM]: net/atm/ioctl.c: autoload pppoatm and br2684
#   
#   Signed-off-by: Roman Kagan <rkagan@mail.ru>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/net/atm/ioctl.c b/net/atm/ioctl.c
--- a/net/atm/ioctl.c	2005-05-07 09:16:19 -04:00
+++ b/net/atm/ioctl.c	2005-05-07 09:16:19 -04:00
@@ -104,16 +104,34 @@
 			if (!error)
 				sock->state = SS_CONNECTED;
 			goto done;
-		default:
+		case ATM_SETBACKEND:
+		case ATM_NEWBACKENDIF:
+			{
+				atm_backend_t backend;
+				error = get_user(backend, (atm_backend_t __user *) argp);
+				if (error)
+					goto done;
+				switch (backend) {
+					case ATM_BACKEND_PPP:
+						request_module("pppoatm");
+						break;
+					case ATM_BACKEND_BR2684:
+						request_module("br2684");
+						break;
+				}
+			}
+			break;
+		case ATMMPC_CTRL:
+		case ATMMPC_DATA:
+			request_module("mpoa");
+			break;
+		case ATMARPD_CTRL:
+			request_module("clip");
+			break;
+		case ATMLEC_CTRL:
+			request_module("lec");
 			break;
 	}
-
-	if (cmd == ATMMPC_CTRL || cmd == ATMMPC_DATA)
-		request_module("mpoa");
-	if (cmd == ATMARPD_CTRL)
-		request_module("clip");
-	if (cmd == ATMLEC_CTRL)
-		request_module("lec");
 
 	error = -ENOIOCTLCMD;
 
