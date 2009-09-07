From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net_sched 07/07: add classful multiqueue dummy scheduler
Date: Mon, 7 Sep 2009 20:22:20 +0200
Message-ID: <20090907182220.GB4451@ami.dom.local>
References: <20090906200409.GB8833@ami.dom.local>
 <4AA50A49.7010905@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:58811 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbZIGSWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 14:22:37 -0400
Received: by fxm17 with SMTP id 17so2148495fxm.37
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2009 11:22:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4AA50A49.7010905@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 07, 2009 at 03:27:37PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
...
> >> @@ -1095,10 +1100,16 @@ create_n_graft:
> >>  		q = qdisc_create(dev, &dev->rx_queue,
> >>  				 tcm->tcm_parent, tcm->tcm_parent,
> >>  				 tca, &err);
> >> -	else
> >> -		q = qdisc_create(dev, netdev_get_tx_queue(dev, 0),
> >> +	else {
> >> +		unsigned int ntx = 0;
> >> +
> >> +		if (p && p->ops->cl_ops && p->ops->cl_ops->select_queue)
> >> +			ntx = p->ops->cl_ops->select_queue(p, tcm);
> > 
> > So, this if could be probably made shorter with a common function, but
> > the main point is: this probably works only for qdiscs having mq as a
> > parent, and not below.
> 
> Yes. mq can only be attached to the root however, so its not
> possible to use it as a child qdisc.

I mean this ->select_queue() works OK for a child qdisc of mq, e.g.
htb, but not for a child qdisc of this htb qdisc, e.g. sfq.

Jarek P.
