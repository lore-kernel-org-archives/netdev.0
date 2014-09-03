From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/3] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Wed, 3 Sep 2014 11:31:19 +0200
Message-ID: <20140903113119.245b4746@redhat.com>
References: <20140902143254.1918.8419.stgit@dragon>
	<20140902143538.1918.82870.stgit@dragon>
	<1409671362.3173.108.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54765 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755613AbaICJbp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 05:31:45 -0400
In-Reply-To: <1409671362.3173.108.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 02 Sep 2014 08:22:42 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2014-09-02 at 16:35 +0200, Jesper Dangaard Brouer wrote:
> 
> > This is crazy fast. This measurement is actually "too-high" as
> > 10Gbit/s wirespeed is 14,880,952 (11049 pps too fast).
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > ---
> 
> This looks buggy, you forgot about GSO.

The GSO check is (!skb->next), right(?)

> (You did the test only for first dequeued packet, not the followings)

Ah! yes, for the following packets!


> Make sure you test your patch with something else than pktgen.

I were not using pktgen, but trafgen (raw/af_packet) ;-)
And I've also been using netperf and super_netperf for testing.

pktgen is difficult to use in this scenerio, because it bypass'es the
qdisc layer.  But I have actually (with help from John Fastabend)
constructed a setup, where I add a VLAN interface, which pktgen can
xmit on, which will make packets travel the qdisc layer of the
underlying real device. (pktgen's clone_skb must be 0 in this setup).
So, I'm not currently using pktgen...


> Also, our idea was to use a byte count limit (aka BQL)

It makes sense. I will look into using the BQL limits.


> If we dequeue 8 64KB packets, this patch adds head of line blocking,
> which we fought hard.

I should not be able to add GSO packets to the skb list in
dequeue_skb(), or did I miss something.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
