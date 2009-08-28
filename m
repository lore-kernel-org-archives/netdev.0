From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [Linux-ATM-General] [PATCH] br2684 testing needed for packet loss and performance
Date: Fri, 28 Aug 2009 08:25:30 -0400
Message-ID: <200908281225.n7SCPUC3031293@cmf.nrl.navy.mil>
References: <4A97B3A9.6040103@hiramoto.org>
Reply-To: chas3@users.sourceforge.net
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: Karl Hiramoto <karl@hiramoto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:60673 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594AbZH1M0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 08:26:45 -0400
Reply-To: chas3@users.sourceforge.net
In-reply-to: <4A97B3A9.6040103@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <4A97B3A9.6040103@hiramoto.org>,Karl Hiramoto writes:
>Anyone care to test or comment on  these patches?  I've attached 
>versions for 2.6.28 and 2.6.30.

this needs to be against the net-2.6 git repository.  but the 2.6.30
would probably apply just fine.  except for the comments, below this
patch looks fine and makes sense.  a similar thing had to be done for
the lec.c interface.

>+/* chained vcc->pop function.  Check if we should wake the netif_queue */
>+static void br2684_pop(struct atm_vcc *vcc, struct sk_buff *skb)
>+{
>+	struct br2684_vcc *brvcc = BR2684_VCC(vcc);
>+	struct net_device *net_dev = brvcc->device;
>+
>+	pr_debug("br2684_pop(vcc %p ; net_dev %p )\n", vcc, net_dev);
>+	brvcc->old_pop(vcc, skb);
>+
>+	if (!net_dev)
>+		return;
>+
>+ 	if (atm_may_send(vcc, 0)) {
>+		netif_wake_queue(net_dev);
>+ 	}

you dont need the { } here.

>+
>+	if (!atm_may_send(atmvcc, 0)) {
>+  		netif_stop_queue(brvcc->device);
>+		barrier();
>+		/* check for race with br26864_pop*/
>+		if (atm_may_send(atmvcc, 0)) {
>+			netif_start_queue(brvcc->device);
>+		}
>+	}
>+

i dont think the barrier() is necessary.
