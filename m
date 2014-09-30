From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Tue, 30 Sep 2014 05:38:41 -0700
Message-ID: <1412080721.30721.72.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140930085114.24043.81310.stgit@dragon>
	 <1412077736.30721.54.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140930122509.GF11709@breakpoint.cc>
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
Received: from mail-pd0-f179.google.com ([209.85.192.179]:48446 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521AbaI3Mio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 08:38:44 -0400
Received: by mail-pd0-f179.google.com with SMTP id r10so4574725pdi.38
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 05:38:44 -0700 (PDT)
In-Reply-To: <20140930122509.GF11709@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-30 at 14:25 +0200, Florian Westphal wrote:
> You're right, but this is not related to this patch specifically.
> But sure, we can look into moving validate_xmit_skb calls outside of the
> qdisc root locked sections.

Yes please.

> 
> > 2) TSO support. Have you ideas how to perform this ?
> 
> Yes, the idea was to just remove the skb_is_gso() test and limit
> dql_avail() result to e.g. 128k to avoid a '8-fat-gso-skbs-in-a-row' scenario.

Really I think you are mistaken about GSO/TSO being fat skb. This is not
a qdisc concern, but packets producer. Think of TSO autosizing which
already takes care of this.

> 
> Did you have any other ideas in mind?

I guess my question was more like : Should I wait you sending patches,
or should I do this ?

We are approaching merge window, and I would like to get this sorted out
for linux-3.18

Thanks
