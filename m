From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: dummy: make use of multi-queues
Date: Wed, 26 Mar 2014 19:52:28 -0700
Message-ID: <1395888748.12610.279.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395880676-4472-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:50864 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098AbaC0Cwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 22:52:30 -0400
Received: by mail-pb0-f43.google.com with SMTP id um1so2822316pbc.30
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 19:52:29 -0700 (PDT)
In-Reply-To: <1395880676-4472-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-27 at 01:37 +0100, Daniel Borkmann wrote:
> Quite often it can be useful to just use the dummy device as a blackhole
> sink for skbs, e.g. for packet sockets or pktgen tests. Therefore, make
> use of multiqueues, so that we can simulate for that. trafgen mmap/TX_RING
> example against dummy device with config foo: { fill(0xff, 64) } results
> in the following performance improvements on an ordinary Core i7/2.80GHz
> as we don't need to take a single queue/lock anymore:

btw, this driver has percpu stats, so memory needs will explode with
your patch...
