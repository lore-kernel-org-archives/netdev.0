From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: [PATCH v2] can: test size of struct sockaddr in sendmsg
Date: Sat, 15 Jan 2011 20:39:16 +0100
Message-ID: <20110115193916.GC463@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch makes the CAN socket code conform to the manpage of sendmsg.

Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Acked-by: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
---
 net/can/bcm.c |    3 +++
 net/can/raw.c |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/can/bcm.c b/net/can/bcm.c
index 6faa825..2f804e4 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1256,6 +1256,9 @@ static int bcm_sendmsg(struct kiocb *iocb, struct socket *sock,
 		struct sockaddr_can *addr =
 			(struct sockaddr_can *)msg->msg_name;
 
+		if (msg->msg_namelen < sizeof(*addr))
+			return -EINVAL;
+
 		if (addr->can_family != AF_CAN)
 			return -EINVAL;
 
diff --git a/net/can/raw.c b/net/can/raw.c
index e88f610..883e9d7 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -649,6 +649,9 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 		struct sockaddr_can *addr =
 			(struct sockaddr_can *)msg->msg_name;
 
+		if (msg->msg_namelen < sizeof(*addr))
+			return -EINVAL;
+
 		if (addr->can_family != AF_CAN)
 			return -EINVAL;
