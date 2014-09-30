From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [net-next PATCH] dql: add a burst attribute
Date: Tue, 30 Sep 2014 08:39:13 -0700
Message-ID: <CAA93jw5Xz132yUT83NW3JsO80byH8o00h2pswjarUazqwSErRw@mail.gmail.com>
References: <20140930085114.24043.81310.stgit@dragon>
	<1412080482.30721.68.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412081485.30721.75.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140930134655.GA24565@breakpoint.cc>
	<1412086646.30721.81.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140930152651.GC24565@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:55306 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbaI3PjO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 11:39:14 -0400
Received: by mail-wi0-f173.google.com with SMTP id bs8so4630033wib.6
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 08:39:13 -0700 (PDT)
In-Reply-To: <20140930152651.GC24565@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2014 at 8:26 AM, Florian Westphal <fw@strlen.de> wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Tue, 2014-09-30 at 15:46 +0200, Florian Westphal wrote:
>> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > > From: Eric Dumazet <edumazet@google.com>
>> > >
>> > > Add a new dql attribute, to control how much packets we are allo=
wed to
>> > > burst from qdisc to device.
>> >
>> > I understand the motivation for this, but I find it a bit out-of-p=
lace
>> > to have a 'packet' type counter in bql context?
>> >
>> > Would it perhaps make more sense to restrict bulk dequeues by an u=
pper
>> > (possibly changeable from userspace) byte counter limit?
>>
>> The byte count is already provided : its the BQL limit.
>> We already have ways to tune it (limit_min & limit_max)
>> We do not think we need something else here.
>
> So you're saying that a bulk dequeue should just grab as many skbs
> as possible until no more available or dql_avail exhausted?
>
> The "magic" value was just to be conservative and not induce any
> hol blocking, which is also why Jesper reduced it again in the latest
> submission.
>
> Then, we might later be able to remove the TSO restriction and switch
> to a pure byte-based limit.
>
> (I don't think having a packet-based count makes sense once tso/gso
>  skbs can be bulk dequeued).
>
> Sorry for the confusion.

I still have some hope that we can one day fix wifi packet aggregation,
which is a limit of 42 packets or 64k bytes per aggregate (best case),
with something BQL-like.

As for the size of the tx ring problem vs GSO, there is at least one
driver with a very limited tx ring that I can think of that tears apart
GSO packets in the driver... but I'm not sure if it's mainlined.

I would not mind at all if TSO/GSO were banned on devices running
slower than 100Mbit.

Perhaps exporting the tx-ring size would be saner than a burst
parameter?

--=20
Dave T=C3=A4ht

https://www.bufferbloat.net/projects/make-wifi-fast
