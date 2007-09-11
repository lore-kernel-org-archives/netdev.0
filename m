From: jamal <hadi@cyberus.ca>
Subject: Re: 2.6.23-rc5: possible irq lock inversion dependency detected
Date: Mon, 10 Sep 2007 20:04:41 -0400
Message-ID: <1189469081.14002.3.camel@localhost>
References: <alpine.DEB.0.999.0709021455510.7103@sheep.housecafe.de>
	 <20070910130024.GA27939@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-AXrL5eGz+7zP0sPzLQwn"
Cc: Christian Kujau <lists@nerdbynature.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762009AbXIKAE7@vger.kernel.org>
In-Reply-To: <20070910130024.GA27939@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-AXrL5eGz+7zP0sPzLQwn
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2007-10-09 at 21:00 +0800, Herbert Xu wrote:


> The minimal fix would be to make sure that we disable BH on
> the first CPU. 

disabling BH would make it more symmetric to the way we handle
egress. I couldnt reproduce the issue, but this should hopefully resolve
it.
Christian, can you test with this patch?

cheers,
jamal





--=-AXrL5eGz+7zP0sPzLQwn
Content-Disposition: attachment; filename=ing1
Content-Type: text/plain; name=ing1; charset=us-ascii
Content-Transfer-Encoding: 7bit

[NET_SCHED] make ingress qlock symmetric to egress

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

--- a/net/sched/sch_generic.c	2007/09/10 23:19:45	1.1
+++ b/net/sched/sch_generic.c	2007/09/10 23:52:45
@@ -42,12 +42,12 @@
 void qdisc_lock_tree(struct net_device *dev)
 {
 	spin_lock_bh(&dev->queue_lock);
-	spin_lock(&dev->ingress_lock);
+	spin_lock_bh(&dev->ingress_lock);
 }
 
 void qdisc_unlock_tree(struct net_device *dev)
 {
-	spin_unlock(&dev->ingress_lock);
+	spin_unlock_bh(&dev->ingress_lock);
 	spin_unlock_bh(&dev->queue_lock);
 }
 

--=-AXrL5eGz+7zP0sPzLQwn--
