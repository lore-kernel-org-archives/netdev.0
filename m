From: jamal <hadi@cyberus.ca>
Subject: Re: Fw: Log full of "ing_filter:  fixed  ippp2 out ippp2"
Date: 10 Mar 2005 21:20:47 -0500
Message-ID: <1110507647.1088.82.camel@jzny.localdomain>
References: <20050310174915.3148c9a8.akpm@osdl.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-LruYe0NJ6hHmL9sT3hgS"
Cc: netdev@oss.sgi.com, Kimmo Sundqvist <kimmo.sundqvist@mbnet.fi>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050310174915.3148c9a8.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-LruYe0NJ6hHmL9sT3hgS
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Does this fix it?

On Thu, 2005-03-10 at 20:49, Andrew Morton wrote:
> Can you check to see if 2.6.11 is still doing this?
> 
> 
> Begin forwarded message:
> 
> Date: Wed, 9 Mar 2005 22:07:41 +0200
> From: Kimmo Sundqvist <kimmo.sundqvist@mbnet.fi>
> To: linux-kernel@vger.kernel.org
> Subject: Log full of "ing_filter:  fixed  ippp2 out ippp2"
> 
> 
> Hello
> 
> Please cc all replies to me.
> 
> After upgrading my little NATting firewall/router from 2.6.7-ck4 to 
> 2.6.10-gentoo-r6 my /var/log/messages is 15MB in size and most of it looks 
> like the text below.  All traffic to the Internet seems to cause this.  
> 
> "cat /var/log/messages | uniq | uniqmessages" results in a 3MB file.  I use 
> syslog-ng.


--=-LruYe0NJ6hHmL9sT3hgS
Content-Disposition: attachment; filename=isdn_p
Content-Type: text/plain; name=isdn_p; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/drivers/isdn/i4l/isdn_net.c	2005-03-02 02:38:33.000000000 -0500
+++ b/drivers/isdn/i4l/isdn_net.c	2005-03-10 21:15:59.451485136 -0500
@@ -1786,6 +1786,7 @@
 		lp->stats.rx_bytes += skb->len;
 	}
 	skb->dev = ndev;
+	skb->input_dev = ndev;
 	skb->pkt_type = PACKET_HOST;
 	skb->mac.raw = skb->data;
 #ifdef ISDN_DEBUG_NET_DUMP
--- a/drivers/isdn/i4l/isdn_ppp.c	2005-03-02 02:38:13.000000000 -0500
+++ b/drivers/isdn/i4l/isdn_ppp.c	2005-03-10 21:12:47.069731608 -0500
@@ -1178,6 +1178,7 @@
 		mlp->huptimer = 0;
 #endif /* CONFIG_IPPP_FILTER */
 	skb->dev = dev;
+	skb->input_dev = dev;
 	skb->mac.raw = skb->data;
 	netif_rx(skb);
 	/* net_dev->local->stats.rx_packets++; done in isdn_net.c */

--=-LruYe0NJ6hHmL9sT3hgS--
