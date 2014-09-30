From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Tue, 30 Sep 2014 05:34:42 -0700
Message-ID: <1412080482.30721.68.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140930085114.24043.81310.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:56503 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbaI3Mep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 08:34:45 -0400
Received: by mail-pa0-f44.google.com with SMTP id et14so4690506pad.31
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 05:34:45 -0700 (PDT)
In-Reply-To: <20140930085114.24043.81310.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-30 at 10:53 +0200, Jesper Dangaard Brouer wrote:

> For now, as a conservative approach, don't bulk dequeue GSO and
> segmented GSO packets, because testing showed requeuing occuring
> with segmented GSO packets.

Note that GSO happens after qdisc dequeue.

We should not care if part of a GSO train is stopped because TX ring is
full. If we stop a GSO train, then we only lower GRO aggregation for the
receiver.

Normally, if BQL is properly working, we should practically not hit TX
ring buffer limit, unless you send very small packets just to stress the
thing (synthetic benchmark, not a real workload)

We should not stop a GSO train because of BQL : Remind that BQL is to
avoid head of line blocking, but there is no way another high prio
packet can be sent on the wire before one if the packet resulting of GSO
segments.

So telling that requeueing is happening with GSO is kind of irrelevant.
