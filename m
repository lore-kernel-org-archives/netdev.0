From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 25/25] NFS: Verify IPv6 addresses properly
Date: Tue, 13 Nov 2007 13:33:12 -0500
Message-ID: <20071113183312.5087.80253.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Add support to nfs_verify_server_address for recognizing AF_INET6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfs/super.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c066016..f0af79b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -46,6 +46,7 @@
 #include <linux/vfs.h>
 #include <linux/inet.h>
 #include <linux/in6.h>
+#include <net/ipv6.h>
 #include <linux/nfs_xdr.h>
 #include <linux/magic.h>
 #include <linux/parser.h>
@@ -601,14 +602,14 @@ static int nfs_set_address_port(struct sockaddr *sap, unsigned short port)
  */
 static int nfs_verify_server_address(struct sockaddr_storage *ssp)
 {
-	struct sockaddr *addr = (struct sockaddr *)ssp;
-
-	switch (addr->sa_family) {
+	switch (ssp->ss_family) {
 	case AF_INET: {
-		struct sockaddr_in *sa = (struct sockaddr_in *) addr;
-		if (sa->sin_addr.s_addr != INADDR_ANY)
-			return 1;
-		break;
+		struct sockaddr_in *sa = (struct sockaddr_in *)ssp;
+		return sa->sin_addr.s_addr != INADDR_ANY;
+	}
+	case AF_INET6: {
+		struct in6_addr *sa = &((struct sockaddr_in6 *)ssp)->sin6_addr;
+		return !ipv6_addr_any(sa);
 	}
 	}
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
