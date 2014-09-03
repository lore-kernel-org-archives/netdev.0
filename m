From: Florian Westphal <fw@strlen.de>
Subject: Re: [net-next PATCH 2/3] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Wed, 3 Sep 2014 12:23:10 +0200
Message-ID: <20140903102310.GA27002@breakpoint.cc>
References: <20140902143254.1918.8419.stgit@dragon>
 <20140902143538.1918.82870.stgit@dragon>
 <1409671362.3173.108.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140903113119.245b4746@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:51450 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754336AbaICKXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 06:23:15 -0400
Content-Disposition: inline
In-Reply-To: <20140903113119.245b4746@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> On Tue, 02 Sep 2014 08:22:42 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Tue, 2014-09-02 at 16:35 +0200, Jesper Dangaard Brouer wrote:
> > 
> > > This is crazy fast. This measurement is actually "too-high" as
> > > 10Gbit/s wirespeed is 14,880,952 (11049 pps too fast).
> > > 
> > > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > > ---
> > 
> > This looks buggy, you forgot about GSO.
> 
> The GSO check is (!skb->next), right(?)

No, you'd want to use skb_is_gso() helper.

> > Also, our idea was to use a byte count limit (aka BQL)
> 
> It makes sense. I will look into using the BQL limits.

Thanks Jesper.

> > If we dequeue 8 64KB packets, this patch adds head of line blocking,
> > which we fought hard.

Just to make sure: Using bql limits would resolve your HOL blocking
concerns, right?
