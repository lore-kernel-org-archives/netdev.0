From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: take 2 WAS (RE: [RFC] make qdisc_restart more readable
Date: Fri, 11 May 2007 15:01:20 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902D4280E@orsmsx414.amr.corp.intel.com>
References: <1178911773.4126.26.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <hadi@cyberus.ca>, "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26708 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759057AbXEKWBY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 18:01:24 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1178911773.4126.26.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Ok, booting fine to me;
> if you receive this email, it must have worked. OTOH, if you
> didnt receive this it probably failed ;-> (as the presenter
> said "if you cant hear me in the far corner please raise your hand").
>
> clip away ...

+static inline int
+handle_dev_requeue(struct sk_buff *skb, struct net_device *dev, struct
Qdisc *q)
+{
+
+	if (unlikely(q == &noop_qdisc))
+		kfree_skb(skb);
+	else if (skb->next)
+		dev->gso_skb = skb;
+	else
+		q->ops->requeue(skb, q);
+	/* XXX: Could netif_schedule fail? Or is that fact we are
+	 * requeueing imply the hardware path is closed
+	 * and even if we fail, some interupt will wake us
+	*/
+	netif_schedule(dev);
+	return 0;
+}

The current requeue calls in qdisc_restart() returns a value of 1 to the
upper layer.  If you return 0, the __qdisc_run() won't break from the
while() it seems if you have to successfully requeue a packet.


-static inline int qdisc_restart(struct net_device *dev)
+int
+qdisc_restart(struct net_device *dev)
 {

Why is this no longer defined static?


+	/* we need to refresh q because it may be invalid since we
droped 

<nitpick>
droped = dropped
</nitpick>

That's all I have for now.  I'll try applying it for kicks and see what
happens.

Thanks,

-PJ Waskiewicz
