From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive
 for TCP
Date: Mon, 23 Apr 2012 22:37:26 +0200
Message-ID: <1335213446.5205.65.camel@edumazet-glaptop>
References: <1335173934.3293.84.camel@edumazet-glaptop>
	 <4F958DFD.7010207@hp.com> <1335201795.5205.35.camel@edumazet-glaptop>
	 <20120423.160149.1515408777176168288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org, therbert@google.com,
	ncardwell@google.com, maze@google.com, ycheng@google.com,
	ilpo.jarvinen@helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47374 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754240Ab2DWUhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 16:37:32 -0400
Received: by bkcik5 with SMTP id ik5so8992366bkc.19
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 13:37:31 -0700 (PDT)
In-Reply-To: <20120423.160149.1515408777176168288.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-23 at 16:01 -0400, David Miller wrote:

> Hmmm... why don't we just acknowledge reality and special case ACKs?
> 

Yes why not.


> If a TCP packet is dataless we should just let it go through no matter
> what and with no limits.  It is by definition transient and will not
> get queued up into the socket past this backlog stage.
> 

Even being transient we need a limit. Without copybreak, an ACK can cost
2048+256 bytes.

In my 10Gbit tests (standard netperf using 16K buffers), I've seen
backlogs of 300 ACK packets...

> This proposed patch allows non-dataless packets to eat more space in
> the backlog, thus the concern and slight pushback.  And from another
> perspective, having the stack process data packets which will just
> get dropped when we try to attach it to the receive queue is just
> wasted work.

We could try to coalesce ACKs before backlogging them. I'll work on
this.

Thanks
