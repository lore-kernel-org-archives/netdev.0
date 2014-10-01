From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next PATCH] dql: add a burst attribute
Date: Tue, 30 Sep 2014 21:44:50 -0700
Message-ID: <CA+mtBx85Qtbu-r=5Bfo9tp+VnX6D_RrQpvCV-R3VubZGOedydQ@mail.gmail.com>
References: <20140930085114.24043.81310.stgit@dragon>
	<1412080482.30721.68.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412081485.30721.75.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140930134655.GA24565@breakpoint.cc>
	<1412086646.30721.81.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140930143101.GB24565@breakpoint.cc>
	<1412088936.30721.86.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140930234642.3c08b033@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Florian Westphal <fw@strlen.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:53832 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbaJAEov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 00:44:51 -0400
Received: by mail-ie0-f176.google.com with SMTP id rp18so49330iec.7
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 21:44:50 -0700 (PDT)
In-Reply-To: <20140930234642.3c08b033@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2014 at 2:46 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> On Tue, 30 Sep 2014 07:55:36 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> > On Tue, 2014-09-30 at 16:31 +0200, Florian Westphal wrote:
> > > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > > If you feel not comfortable with "burst", rename it to whatever you
> > > > think is best.
> > > > But please, do not hard code magic 7 in your code.
> > >
> > > I had hoped that this 'magic' value could be removed
> > > completely, only using bql data for bulking decisions.
> >
> > But it is apparently not the case, since you guys decided to had it set
> > to 8, then to 7 later, based on experiments.
>
> The "magic" limit is only a conservative save guard.  We do plan to
> remove this completely.  That is the reason for not exporting this, as
> we want free-hands to remove this completely.
>
> Guess, I'll remove it completely now, so we can move on.
>
>
> I would like some off/on switch, exported to userspace, for disabling
> this bulking (then we don't need this conservative magic number).  How
> would that be done best?


I'd suggest to keep the packet limit as an unsigned. Default value is
infinity (-1UL), 0 turns it off, and other values are available if
someone really wants to tune this (for example, if BQL is disabled--
BQL limit is infinity). Export this as sys variable for the TX queue.

Tom

>
>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Sr. Network Kernel Developer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
