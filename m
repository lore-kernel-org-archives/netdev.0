From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Thu, 17 Dec 2009 13:17:09 +0000
Message-ID: <20091217131708.GC8654@ff.dom.local>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com> <20091217112754.GA7755@ff.dom.local> <OF32B8811E.870B9515-ON6525768F.003F57BD-6525768F.0040952B@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:44315 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756511AbZLQNRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 08:17:12 -0500
Received: by fxm21 with SMTP id 21so1870482fxm.21
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 05:17:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <OF32B8811E.870B9515-ON6525768F.003F57BD-6525768F.0040952B@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 05:26:37PM +0530, Krishna Kumar2 wrote:
> Sridhar is seeing 280K requeue's, and that probably implies device
> was stopped and wrongly restarted immediately. So the next xmit in
> the kernel found the txq is not stopped and called the xmit handler,
> get a BUSY, requeue, and so on. That would also explain why his BW
> drops so much - all false starts (besides 19% of all skbs being
> requeued). I assume that each time when we check:
> 
>       if (!netif_tx_queue_stopped(txq) && !netif_tx_queue_frozen(txq))
>             ret = dev_hard_start_xmit(skb, dev, txq);
> it passes the check and dev_hard_start_xmit is called wrongly.
> 
> #Requeues: 283575
> #total skbs: 1469482
> Percentage requeued: 19.29%

I haven't followed this thread, so I'm not sure what are you looking
for, but can't these requeues/drops mean some hardware limits were
reached? I wonder why there are compared linux-2.6.32 vs. 2.6.31.6
with different test conditions (avg. packet sizes: 16800 vs. 64400)?

Jarek P.
