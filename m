From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next PATCH] dql: add a burst attribute
Date: Tue, 30 Sep 2014 07:26:35 -0700
Message-ID: <CA+mtBx8HLPjSLXLH3z_j6zES8cTVpb67EBpFcVv94ANgMkYyTQ@mail.gmail.com>
References: <20140930085114.24043.81310.stgit@dragon>
	<1412080482.30721.68.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412081485.30721.75.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140930134655.GA24565@breakpoint.cc>
	<1412086646.30721.81.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:51096 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860AbaI3O0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 10:26:37 -0400
Received: by mail-ig0-f180.google.com with SMTP id a13so5590209igq.1
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 07:26:36 -0700 (PDT)
In-Reply-To: <1412086646.30721.81.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2014 at 7:17 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-09-30 at 15:46 +0200, Florian Westphal wrote:
>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > From: Eric Dumazet <edumazet@google.com>
>> >
>> > Add a new dql attribute, to control how much packets we are allowed to
>> > burst from qdisc to device.
>>
>> I understand the motivation for this, but I find it a bit out-of-place
>> to have a 'packet' type counter in bql context?
>>
>> Would it perhaps make more sense to restrict bulk dequeues by an upper
>> (possibly changeable from userspace) byte counter limit?
>
> The byte count is already provided : its the BQL limit.
> We already have ways to tune it (limit_min & limit_max)
> We do not think we need something else here.
> That was the whole point of reusing BQL in the first place : Its already
> powerful and implemented.
>
> This new attribute is a packet burst.
>
Yes, this is the wrong place to put it. DQL knows nothing about
packets or technically even bytes, it's a generic library that deal
with "objects" on a queue. I don't see how burst relates to this.

I would infer from the patch that what you want is to add an attribute
to the TX queue. Why not do this directly?

>
> When I suggested 'pburst' attribute for pktgen to Alexei, he sent a
> patch with "burst". Nobody complained.
>
> Now I am reusing what apparently was OK for pktgen, you seem to object.
>
> If you feel not comfortable with "burst", rename it to whatever you
> think is best.
>
> But please, do not hard code magic 7 in your code.
>
> Thanks
>
>
