From: Martijn Hijdra <martijn@esrac.ele.tue.nl>
Subject: Re: [PATCH] hamradio/scc -
Date: Wed, 17 Sep 2003 08:35:41 +0200
Sender: linux-hams-owner@vger.kernel.org
Message-ID: <1063780541.2971.4.camel@imst153.imst.de>
References: <20030915162335.0034a551.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-hN8ySaqxnHj08rJ9vSsJ"
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-hams-owner@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030915162335.0034a551.shemminger@osdl.org>
List-Id: netdev.vger.kernel.org


--=-hN8ySaqxnHj08rJ9vSsJ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2003-09-16 at 01:23, Stephen Hemminger wrote:
> Update hamradio/scc for 2.6.0-test5
> 	- use seq_file for /proc
> 	- get rid of dev_get()
> 	- use alloc_netdev
> 

Hi, and another small patch for hamradio/scc to
fill the statistics counters for the scc driver.
(see output of ifconfig RX bytes and TX bytes)



-- 
Martijn Hijdra <martijn@esrac.ele.tue.nl>

--=-hN8ySaqxnHj08rJ9vSsJ
Content-Disposition: attachment; filename=scc_260t5.diff
Content-Type: text/x-patch; name=scc_260t5.diff; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- drivers/net/hamradio/scc.c.orig	2003-08-23 01:58:57.000000000 +0200
+++ drivers/net/hamradio/scc.c	2003-09-03 08:57:50.000000000 +0200
@@ -1635,6 +1635,7 @@
 	}
 		
 	scc->dev_stat.rx_packets++;
+	scc->dev_stat.rx_bytes += skb->len;
 
 	skb->dev      = scc->dev;
 	skb->protocol = htons(ETH_P_AX25);
@@ -1661,6 +1662,7 @@
 	}
 	
 	scc->dev_stat.tx_packets++;
+	scc->dev_stat.tx_bytes += skb->len;
 	scc->stat.txframes++;
 	
 	kisscmd = *skb->data & 0x1f;
--- include/linux/scc.h.orig	2003-09-03 09:13:26.000000000 +0200
+++ include/linux/scc.h	2003-09-03 09:13:55.000000000 +0200
@@ -200,7 +200,7 @@
 	unsigned char fulldup;		/* Full Duplex mode 0=CSMA 1=DUP 2=ALWAYS KEYED */
 	unsigned char waittime;		/* Waittime before any transmit attempt */
 	unsigned int  maxkeyup;		/* Maximum time to transmit (seconds) */
-	unsigned char mintime;		/* Minimal offtime after MAXKEYUP timeout (seconds) */
+	unsigned int  mintime;		/* Minimal offtime after MAXKEYUP timeout (seconds) */
 	unsigned int  idletime;		/* Maximum idle time in ALWAYS KEYED mode (seconds) */
 	unsigned int  maxdefer;		/* Timer for CSMA channel busy limit */
 	unsigned char tx_inhibit;	/* Transmit is not allowed when set */	

--=-hN8ySaqxnHj08rJ9vSsJ--

