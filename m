From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [KJ] [PATCH 21/39] net/ipconfig: replace schedule_timeout() with
	msleep()
Date: Thu, 20 Jan 2005 15:57:49 -0800
Message-ID: <20050120235749.GJ2600@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============31961530475141875=="
Cc: netdev@oss.sgi.com, kernel-janitors@lists.osdl.org
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@redhat.com,
   yoshfuji@linux-ipv6.org, kaber@coreworks.de
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============31961530475141875==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

Please consider applying.

Description: Use msleep() instead of schedule_timeout() to guarantee the task
delays as expected. Change the units of the two constants to be msecs and secs
respectively.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

--- 2.6.11-rc1-kj-v/net/ipv4/ipconfig.c	2005-01-15 16:55:44.000000000 -0800
+++ 2.6.11-rc1-kj/net/ipv4/ipconfig.c	2005-01-18 13:01:44.000000000 -0800
@@ -53,6 +53,7 @@
 #include <linux/seq_file.h>
 #include <linux/major.h>
 #include <linux/root_dev.h>
+#include <linux/delay.h>
 #include <net/arp.h>
 #include <net/ip.h>
 #include <net/ipconfig.h>
@@ -84,8 +85,8 @@
 #endif
 
 /* Define the friendly delay before and after opening net devices */
-#define CONF_PRE_OPEN		(HZ/2)	/* Before opening: 1/2 second */
-#define CONF_POST_OPEN		(1*HZ)	/* After opening: 1 second */
+#define CONF_PRE_OPEN		500	/* Before opening: 1/2 second */
+#define CONF_POST_OPEN		1	/* After opening: 1 second */
 
 /* Define the timeout for waiting for a DHCP/BOOTP/RARP reply */
 #define CONF_OPEN_RETRIES 	2	/* (Re)open devices twice */
@@ -1259,16 +1260,14 @@ static int __init ip_auto_config(void)
  try_try_again:
 #endif
 	/* Give hardware a chance to settle */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(CONF_PRE_OPEN);
+	msleep(CONF_PRE_OPEN);
 
 	/* Setup all network devices */
 	if (ic_open_devs() < 0)
 		return -1;
 
 	/* Give drivers a chance to settle */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(CONF_POST_OPEN);
+	ssleep(CONF_POST_OPEN);
 
 	/*
 	 * If the config information is insufficient (e.g., our IP address or

--===============31961530475141875==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============31961530475141875==--
