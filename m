From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] packet: respect devices with LLTX flag in
 direct xmit
Date: Thu, 27 Mar 2014 09:04:24 -0700
Message-ID: <1395936264.12610.300.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395934710-29182-1-git-send-email-dborkman@redhat.com>
	 <1395936094.12610.299.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:41694 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696AbaC0QEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 12:04:25 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so3544316pdi.16
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 09:04:25 -0700 (PDT)
In-Reply-To: <1395936094.12610.299.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-27 at 09:01 -0700, Eric Dumazet wrote:

> > +	HARD_TX_LOCK(dev, txq, smp_processor_id());
> > +	if (!netif_xmit_frozen_or_stopped(txq)) {
> > +		ret = ops->ndo_start_xmit(skb, dev);
> > +		if (ret == NETDEV_TX_OK)
> > +			txq_trans_update(txq);


> I think this is problematic.
> 
> If you have concurrent traffic going through txq, and a flood
> going through packet_direct_xmit(), the timeout will trigger on txq
> because we do no longer update txq->trans_start
> 
> So I think you should force the update
> 
> 	txq->trans_start = jiffies;

Oh well, scratch that, I missed that you did the update.
