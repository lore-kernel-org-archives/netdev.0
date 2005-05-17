From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH 11/12] orinoco: monitor mode support
Date: Tue, 17 May 2005 15:43:14 -0400
Message-ID: <1116358994.5534.2.camel@dv.roinet.com>
References: <20050514153100.GL3643@lst.de>
	 <20050514173947.GA32235@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@lst.de>, jgarzik@pobox.com,
        hermes@gibson.dropbear.id.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050514173947.GA32235@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-05-14 at 19:39 +0200, Francois Romieu wrote:
> > + drop:
> > +	stats->rx_errors++;
> > +	stats->rx_dropped++;
> > +}
> 
> -> leak (skb).

Indeed.  Thank you!  Please apply this on top of the original patches:

Signed-off-by: Pavel Roskin <proski@gnu.org>

--- orinoco.c
+++ orinoco.c
@@ -1180,7 +1180,7 @@ static void orinoco_rx_monitor(struct ne
 	u16 fc;
 	int err;
 	int len;
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
 	struct orinoco_private *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &priv->stats;
 	hermes_t *hw = &priv->hw;
@@ -1268,6 +1268,8 @@ static void orinoco_rx_monitor(struct ne
  drop:
 	stats->rx_errors++;
 	stats->rx_dropped++;
+	if (skb)
+		dev_kfree_skb_irq(skb);
 }
 
 static void __orinoco_ev_rx(struct net_device *dev, hermes_t *hw)


-- 
Regards,
Pavel Roskin
