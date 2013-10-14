From: Tino Reichardt <list-linux-netdev@mcmilk.de>
Subject: Re: [PATCH 01/07] 8139too: Support for byte queue limits
Date: Mon, 14 Oct 2013 21:31:55 +0200
Message-ID: <20131014193155.GC23070@mcmilk.de>
References: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
 <1381775183-24866-2-git-send-email-milky-kernel@mcmilk.de>
 <1381777891.2045.1.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:38635 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756419Ab3JNTb6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 15:31:58 -0400
Received: from localhost (localhost [127.0.0.1])
	by lotte.svc-box.de (Postfix) with ESMTP id 39F69148018F
	for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 21:31:57 +0200 (CEST)
Received: from lotte.svc-box.de ([127.0.0.1])
	by localhost (lotte.svc-box.de [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id BS-21FkyFXJH for <netdev@vger.kernel.org>;
	Mon, 14 Oct 2013 21:31:55 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1381777891.2045.1.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2013-10-14 at 20:26 +0200, Tino Reichardt wrote:
> > Changes to 8139too to use byte queue limits.
> > 
> > This patch was not tested on real hardware currently, but compiles fine and
> > should work.
> > 
> >  	tp->cur_tx = 0;
> >  	tp->dirty_tx = 0;
> > +	netdev_reset_queue(tp->dev);
> >  
> >  	/* XXX account for unsent Tx packets in tp->stats.tx_dropped */
> >  }
> > @@ -1733,6 +1735,7 @@ static netdev_tx_t rtl8139_start_xmit (struct sk_buff *skb,
> >  		   tp->tx_flag | max(len, (unsigned int)ETH_ZLEN));
> >  
> >  	tp->cur_tx++;
> > +	netdev_sent_queue(dev, len);
> >  
> 
> This looks wrong if len < ETH_ZLEN

Yes you are right. I looked to the debug statement in the end of that
function, so len had to be correct ... but it isn't ... yes :(

netif_dbg(tp, tx_queued, dev, "Queued Tx packet size %u to slot %d\n"...

Should a make len = max(len, ETH_ZLEN) there .. so the debug statement
is also correct?


-- 
Best regards, TR
