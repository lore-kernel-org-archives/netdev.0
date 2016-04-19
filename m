From: Edward Cree <ecree@solarflare.com>
Subject: Re: [RFC PATCH net-next 2/8] sfc: batch up RX delivery on EF10
Date: Tue, 19 Apr 2016 18:42:47 +0100
Message-ID: <57166E17.6030002@solarflare.com>
References: <5716338E.4050003@solarflare.com>
 <57163404.2000507@solarflare.com>
 <1461077257.10638.185.camel@edumazet-glaptop3.roam.corp.google.com>
 <57165E73.60402@solarflare.com>
 <1461086440.10638.208.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	"Jesper Dangaard Brouer" <brouer@redhat.com>,
	<linux-net-drivers@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:62301 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752915AbcDSRm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 13:42:58 -0400
In-Reply-To: <1461086440.10638.208.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/04/16 18:20, Eric Dumazet wrote:
> It seems all the discussions about fast kernel networking these days is
> adding yet another queues, code duplication and complexity, batches, and
> add latencies, on top of a single NIC RX queue.
>
> Apparently the multiqueue nature of a NIC is obsolete and people want to
> process 10+Mpps on a single queue.
The real goal here is to speed up packet processing generally.
Doing everything on a single queue (and thus a single CPU) is just a
convenient way of measuring that, while making sure performance is limited
by the RX side rather than the TX not being able to generate enough packets
to keep us busy.  Similarly, measuring single-byte UDP packet rate with one
CPU running flat-out is easier than measuring CPU usage while receiving
line-rate TCP in 1400-byte chunks.

> We could probably get ~100% improvement in UDP if we really cared, just
> by changing net/ipv[46]/udp.c, not changing other layers.
Well, I don't know how to achieve that, but it sounds like you do, so why
not go ahead and show us ;)
If you submitted a patch series to make UDP twice as fast, I think people
would "really care" about an improvement of that magnitude.

But RX batching should speed up all traffic, not just UDP.  Or at least,
that's the theory.

-Ed
