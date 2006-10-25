From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific
 qdisc
Date: Thu, 26 Oct 2006 01:29:27 +0200
Message-ID: <453FF357.6060007@trash.net>
References: <20061025220406.GA5413@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:26604 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751116AbWJYX3a
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 19:29:30 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061025220406.GA5413@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Kimdon wrote:
> wme.c needs a generic fifo qdisc for each hardware queue.  Switch 
> wme.c to use the generic fifo qdisc in net/sched/sch_fifo.c.  This allows
> removal of net/d80211/fifo_qdisc.c which isn't particularily tied to
> IEEE 802.11 in any way.
> 
> -#define CHILD_QDISC_OPS pfifo_qdisc_ops
> -
>  static inline int WLAN_FC_IS_QOS_DATA(u16 fc)
>  {
>  	return (fc & 0x8C) == 0x88;
> @@ -433,7 +431,7 @@ static int wme_qdiscop_init(struct Qdisc
>  	/* create child queues */
>  	for (i = 0; i < queues; i++) {
>  		skb_queue_head_init(&q->requeued[i]);
> -		q->queues[i] = qdisc_create_dflt(qd->dev, &CHILD_QDISC_OPS);
> +		q->queues[i] = qdisc_create_dflt(qd->dev, &pfifo_qdisc_ops);
>  		if (q->queues[i] == 0) {
>  			q->queues[i] = &noop_qdisc;
>  			printk(KERN_ERR "%s child qdisc %i creation failed", dev->name, i);
> Index: wireless-dev/net/d80211/Kconfig
> ===================================================================
> --- wireless-dev.orig/net/d80211/Kconfig
> +++ wireless-dev/net/d80211/Kconfig
> @@ -3,6 +3,7 @@ config D80211
>  	select CRYPTO
>  	select CRYPTO_ARC4
>  	select CRYPTO_AES
> +	select NET_SCHED


pfifo_fast is available even without CONFIG_NET_SCHED, maybe
thats a better choice to avoid unnecessary bloat.

