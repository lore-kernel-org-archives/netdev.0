From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Wed, 27 Aug 2014 07:09:35 -0700
Message-ID: <1409148575.3173.47.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>
	 <1409142672.26515.24.camel@localhost>
	 <1409145838.3173.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140827155651.04fe49d0@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, jhs@mojatatu.com, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au,
	dborkman@redhat.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:53091 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934415AbaH0OJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 10:09:41 -0400
Received: by mail-pa0-f50.google.com with SMTP id et14so344553pad.37
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 07:09:38 -0700 (PDT)
In-Reply-To: <20140827155651.04fe49d0@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-08-27 at 15:56 +0200, Jesper Dangaard Brouer wrote:

> I do worry a bit, if writing skb->xmit_more in a more cache cold
> scenarios could hurt us (as that cacheline seems to be read mostly),
> but this is not a problem right now because it will always be cache
> hot, as we always clear the entire SKB in alloc.
> 


Yes, but many of us use things like TCP stack and thousand of packets
sitting in a possibly complex qdisc hierarchy before hitting the
device ;)

In these situations, skb is dirtied at TX completion time, but not in
ndo_start_xmit() (where its only read)

In the (qdisc->dequeue() -> ndo_start_xmit()) stage, only the first
cache line of skb is typically dirtied.
