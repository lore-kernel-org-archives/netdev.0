From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Sat, 23 Aug 2008 12:49:53 -0400
Message-ID: <1219510193.4732.26.camel@localhost>
References: <1219415417.4672.79.camel@localhost>
	 <20080822221913.GA2981@ami.dom.local>
	 <20080822.173348.232018958.davem@davemloft.net>
	 <20080823084715.GA2515@ami.dom.local>
	 <5f2db9d90808230931n453a3b75q84153dd8c18bcfc2@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:43026 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbYHWQt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 12:49:58 -0400
Received: by rv-out-0506.google.com with SMTP id k40so960301rvb.1
        for <netdev@vger.kernel.org>; Sat, 23 Aug 2008 09:49:57 -0700 (PDT)
In-Reply-To: <5f2db9d90808230931n453a3b75q84153dd8c18bcfc2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-23-08 at 09:31 -0700, Alexander Duyck wrote:

> Actually in this new multiple tx queue kernel this qdisc could serve a
> very specific but needed purpose which just became apparent to me.
> This qdisc resolves one very specific issue, head-of-line blocking if
> one of the hardware queues is full.  What if I reversed things a bit
> in prio_classify so that skb->queue_mapping determined the band
> instead of the other way around in the case of the multiqueue option
> being enabled?  I would think that in this configuration the qdisc
> would prove to be pretty useful for purposes other than QOS since it
> would allow a classful qdisc per transmit queue instead of per device.
> 

i think thats whats Dave is saying not in so many words.

prio_classify calls classifiers.
dont modify the qdisc; rather do a classification which when matched
sets skb->queue_mapping to a value your policy likes it to be.  
you dont need a new classifier, u32 would do for example. or ematch if
you want to do some funky things. you will need a new action which sets
the skb->queue_mapping.

> I could then create a select_queue for the device that returns 0 when
> in DCB/EEDC mode for our drivers, implement the tc action to set the
> queue mapping, and have essentially the same result as I had before.
> 

put overflow queues in your driver. With the new multiq approach the
controls are per-queue not per driver.

cheers,
jamal

