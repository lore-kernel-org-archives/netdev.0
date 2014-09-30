From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next PATCH] dql: add a burst attribute
Date: Tue, 30 Sep 2014 08:05:48 -0700
Message-ID: <CA+mtBx-fVX33qOJewe2wS=77m-q+YtfnPStFX=2CWf7c7HrQdw@mail.gmail.com>
References: <20140930085114.24043.81310.stgit@dragon>
	<1412080482.30721.68.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412081485.30721.75.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140930134655.GA24565@breakpoint.cc>
	<1412086646.30721.81.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx8HLPjSLXLH3z_j6zES8cTVpb67EBpFcVv94ANgMkYyTQ@mail.gmail.com>
	<1412088549.30721.84.camel@edumazet-glaptop2.roam.corp.google.com>
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
Received: from mail-ie0-f182.google.com ([209.85.223.182]:60074 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbaI3PFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 11:05:49 -0400
Received: by mail-ie0-f182.google.com with SMTP id tp5so16957923ieb.27
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 08:05:48 -0700 (PDT)
In-Reply-To: <1412088549.30721.84.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2014 at 7:49 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-09-30 at 07:26 -0700, Tom Herbert wrote:
>
>
>> Yes, this is the wrong place to put it. DQL knows nothing about
>> packets or technically even bytes, it's a generic library that deal
>> with "objects" on a queue. I don't see how burst relates to this.
>
> I wonder then why you put :
>
> netdev_tx_completed_queue(struct netdev_queue *dev_queue,
>                           unsigned int pkts, unsigned int bytes)
>
In case we ever wanted to count by packets instead of or in addition to bytes.

> Really, I don't care _where_ the attribute is, as long we dont access
> yet another cache line in fast path.

Just put it after/before dql in netdev_queue structure.

>
>
>
