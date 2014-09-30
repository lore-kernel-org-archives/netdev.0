From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] dql: add a burst attribute
Date: Tue, 30 Sep 2014 07:17:26 -0700
Message-ID: <1412086646.30721.81.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140930085114.24043.81310.stgit@dragon>
	 <1412080482.30721.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412081485.30721.75.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140930134655.GA24565@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:59133 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbaI3OR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 10:17:29 -0400
Received: by mail-pd0-f171.google.com with SMTP id ft15so3479716pdb.16
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 07:17:29 -0700 (PDT)
In-Reply-To: <20140930134655.GA24565@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-30 at 15:46 +0200, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Add a new dql attribute, to control how much packets we are allowed to
> > burst from qdisc to device.
> 
> I understand the motivation for this, but I find it a bit out-of-place
> to have a 'packet' type counter in bql context?
> 
> Would it perhaps make more sense to restrict bulk dequeues by an upper
> (possibly changeable from userspace) byte counter limit?

The byte count is already provided : its the BQL limit.
We already have ways to tune it (limit_min & limit_max)
We do not think we need something else here.
That was the whole point of reusing BQL in the first place : Its already
powerful and implemented.

This new attribute is a packet burst.


When I suggested 'pburst' attribute for pktgen to Alexei, he sent a
patch with "burst". Nobody complained.

Now I am reusing what apparently was OK for pktgen, you seem to object.

If you feel not comfortable with "burst", rename it to whatever you
think is best.

But please, do not hard code magic 7 in your code.

Thanks
