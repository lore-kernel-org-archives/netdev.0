From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH 2/2] ray_cs: reduce stack usage (sockaddr)
Date: Fri, 28 Jan 2005 14:13:20 -0800
Message-ID: <41FAB900.5020502@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060808060506010503030508"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, jgarzik@pobox.com, corey@world.std.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060808060506010503030508
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


ray_cs:  reduce local stack size in ray_dev_ioctl() from 468
   to 340 bytes by having only 1 of these 128-byte arrays (which
   is now at function scope):
	struct sockaddr       address[IW_MAX_SPY];
		16			 * 8	= 128

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
  drivers/net/wireless/ray_cs.c |    5 +++--
  1 files changed, 3 insertions(+), 2 deletions(-)

--------------060808060506010503030508
Content-Type: text/x-patch;
 name="raycs_stack2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="raycs_stack2.patch"


diff -Naurp ./drivers/net/wireless/ray_cs.c~raycs_sockaddr ./drivers/net/wireless/ray_cs.c
--- ./drivers/net/wireless/ray_cs.c~raycs_sockaddr	2005-01-27 21:05:51.000000000 -0800
+++ ./drivers/net/wireless/ray_cs.c	2005-01-28 14:00:02.129647488 -0800
@@ -1215,6 +1215,9 @@ static int ray_dev_ioctl(struct net_devi
 #if WIRELESS_EXT > 7
     struct iwreq *wrq = (struct iwreq *) ifr;
 #endif	/* WIRELESS_EXT > 7 */
+#ifdef WIRELESS_SPY
+    struct sockaddr	address[IW_MAX_SPY];
+#endif	/* WIRELESS_SPY */
 
     if (!(link->state & DEV_PRESENT)) {
         DEBUG(2,"ray_dev_ioctl - device not present\n");
@@ -1517,7 +1520,6 @@ static int ray_dev_ioctl(struct net_devi
       /* If there is some addresses to copy */
       if(local->spy_number > 0)
 	{
-	  struct sockaddr	address[IW_MAX_SPY];
 	  int			i;
 
 	  /* Copy addresses to the driver */
@@ -1557,7 +1559,6 @@ static int ray_dev_ioctl(struct net_devi
       /* If the user want to have the addresses back... */
       if((local->spy_number > 0) && (wrq->u.data.pointer != (caddr_t) 0))
 	{
-	  struct sockaddr	address[IW_MAX_SPY];
 	  int			i;
 
 	  /* Copy addresses from the lp structure */

--------------060808060506010503030508--
