From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: LLTX and netif_stop_queue
Date: 19 Dec 2004 15:02:24 -0500
Message-ID: <1103486544.1049.169.camel@jzny.localdomain>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
	<1103484675.1050.158.camel@jzny.localdomain>
	<1103486090.1047.166.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-G0Wb++BCRuJsoWHykTou"
Cc: netdev@oss.sgi.com, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1103486090.1047.166.camel@jzny.localdomain>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org


--=-G0Wb++BCRuJsoWHykTou
Content-Transfer-Encoding: 7bit
Content-Type: text/plain


On Sun, 2004-12-19 at 14:54, jamal wrote:
> On Sun, 2004-12-19 at 14:31, jamal wrote:
> 
> > How about releasing the qlock only when the LLTX transmit lock is
> > grabbed? That should bring it to par with what it was originally.
> 
> Something like two attached patches... one showing how to do it for
> e1000. untested (not even compiled)

After attempting to compile, p2 take2.

cheers,
jamal

--=-G0Wb++BCRuJsoWHykTou
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=p2-take2
Content-Type: text/plain; name=p2-take2; charset=ISO-8859-1

--- 2610-rc3-bk12/drivers/net/e1000/bak.e1000_main.c	2004-12-19 13:50:59.000000000 -0500
+++ 2610-rc3-bk12/drivers/net/e1000/e1000_main.c	2004-12-19 13:58:17.000000000 -0500
@@ -1809,6 +1809,10 @@
  		return NETDEV_TX_LOCKED; 
  	} 
 
+	/* new from sch_generic for LLTX */
+	spin_unlock(&netdev->queue_lock);
+	netdev->xmit_lock_owner = smp_processor_id();
+
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
 	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2) {

--=-G0Wb++BCRuJsoWHykTou
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--=-G0Wb++BCRuJsoWHykTou--
