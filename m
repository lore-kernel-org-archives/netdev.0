From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] nicstar: use kernel min/max
Date: Wed, 25 Feb 2004 21:32:29 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040225213229.66ac8d54.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.3-current.

--
~Randy


From: Michael Veeck <michael.veeck@gmx.net>


Patch (against 2.6.3) removes unnecessary min/max macros and changes
calls to use kernel.h macros instead.

Feedback is always welcome
Michael


 linux-263-223-kj1-rddunlap/drivers/atm/nicstar.c |    5 +----
 1 files changed, 1 insertion(+), 4 deletions(-)


diff -puN drivers/atm/nicstar.c~atm_nicstar_minmax drivers/atm/nicstar.c
--- linux-263-223-kj1/drivers/atm/nicstar.c~atm_nicstar_minmax	2004-02-24 11:03:02.000000000 -0800
+++ linux-263-223-kj1-rddunlap/drivers/atm/nicstar.c	2004-02-24 11:03:02.000000000 -0800
@@ -112,9 +112,6 @@
 
 /* Macros *********************************************************************/
 
-#define MAX(a,b) ((a) > (b) ? (a) : (b))
-#define MIN(a,b) ((a) < (b) ? (a) : (b))
-
 #define CMD_BUSY(card) (readl((card)->membase + STAT) & NS_STAT_CMDBZ)
 
 #define NS_DELAY mdelay(1)
@@ -2483,7 +2480,7 @@ static void dequeue_rx(ns_dev *card, ns_
             for (j = 1; j < NS_SKB(iovb)->iovcnt; j++)
             {
                lb = (struct sk_buff *) iov->iov_base;
-               tocopy = MIN(remaining, iov->iov_len);
+               tocopy = min_t(int, remaining, iov->iov_len);
                memcpy(hb->tail, lb->data, tocopy);
                skb_put(hb, tocopy);
                iov++;

_
