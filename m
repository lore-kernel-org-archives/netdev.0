From: jamal <hadi@cyberus.ca>
Subject: Re: [NET]: Prevent multiple qdisc runs
Date: Mon, 19 Jun 2006 10:23:29 -0400
Message-ID: <1150727009.5815.72.camel@jzny2>
References: <20060619121519.GA16031@gondor.apana.org.au>
	 <1150724031.5815.39.camel@jzny2>
	 <20060619134227.GA16662@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:59320 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932463AbWFSOXd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 10:23:33 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FsKfA-0000JK-84
	for netdev@vger.kernel.org; Mon, 19 Jun 2006 10:23:36 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060619134227.GA16662@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert,

On Mon, 2006-19-06 at 23:42 +1000, Herbert Xu wrote:
> Hi Jamal:
> 
> On Mon, Jun 19, 2006 at 09:33:51AM -0400, jamal wrote:
[..]
> 
> Actually I discovered the problem only because the generic segmentation
> offload stuff that I'm working on needs to deal with the situation where
> a super-packet is partially transmitted.  Requeueing causes all sorts of
> nasty problems so I chose to keep it within the net_device structure.
>
> To do so requires qdisc_run to be serialised against each other.  I then
> found out that we want this anyway because otherwise the requeued packets
> could be reordered.
> 

Ok, I am trying to visualize but having a hard time:
Re-queueing is done at the front of the queue to maintain ordering
whereas queueing is done at the front (i.e it is a FIFO). i,e
even if p2 comes in and gets queued while p1 is being processed,
requeueing of p1 will put it infront of p2.
Your super-packet issue may be different though ..

> > Also: what happens to the packet that comes in from either local or is
> > being forwarded and finds the qdisc_is_running flag is set? I couldnt
> > tell if the intent was to drop it or not. The answer for TCP is probably
> > simpler than for packets being forwarded.
> 
> The qdisc_is_running only prevents qdisc_run from occuring (because it's
> already running), it does not impact on the queueing of the packet.
> 

I will wait for your answer on the other part before responding to this.

cheers,
jamal


