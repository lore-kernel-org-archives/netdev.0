From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Wed, 27 Aug 2014 13:51:19 -0700 (PDT)
Message-ID: <20140827.135119.1651012580949456343.davem@davemloft.net>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>
	<CAHA+R7MJX3Du8ggOo2GqGA4rXvY30YOpCFqS4PBN2ZNE=kwKuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au,
	dborkman@redhat.com, brouer@redhat.com
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40290 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932159AbaH0UvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 16:51:21 -0400
In-Reply-To: <CAHA+R7MJX3Du8ggOo2GqGA4rXvY30YOpCFqS4PBN2ZNE=kwKuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Wed, 27 Aug 2014 11:28:25 -0700

> But for me, it looks like you are trying to pend some more packets
> in a TX queue until the driver decides to flush them all in one shot.
> So if that is true, doesn't this mean the latency of first packet pending
> in this queue will increase and network traffic will be more bursty for
> the receiver??

We intend to turn this so that it doesn't introduce latency.

The situation where we have the largest opportunity to perform
this batching is when the device queue has been stopped and is
started back up.

Usually at this moment the TX queue is %75 full and we have room
now for a couple of packets.

Therefore, delaying the triggering of the TX for this new set of
packets will have no effect on latency because the device is still
busy transmitting the rest of the TX queue.
