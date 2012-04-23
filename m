From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive
 for TCP
Date: Tue, 24 Apr 2012 00:05:07 +0200
Message-ID: <1335218707.5205.87.camel@edumazet-glaptop>
References: <1335173934.3293.84.camel@edumazet-glaptop>
	 <4F958DFD.7010207@hp.com> <1335201795.5205.35.camel@edumazet-glaptop>
	 <20120423.160149.1515408777176168288.davem@davemloft.net>
	 <1335213446.5205.65.camel@edumazet-glaptop>  <4F95C22D.3010908@hp.com>
	 <1335216631.5205.71.camel@edumazet-glaptop>  <4F95CECF.6030901@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, ncardwell@google.com, maze@google.com,
	ycheng@google.com, ilpo.jarvinen@helsinki.fi
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:60609 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754579Ab2DWWFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 18:05:12 -0400
Received: by wgbds11 with SMTP id ds11so2946536wgb.1
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 15:05:10 -0700 (PDT)
In-Reply-To: <4F95CECF.6030901@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-23 at 14:51 -0700, Rick Jones wrote:
> On 04/23/2012 02:30 PM, Eric Dumazet wrote:

> > Yet, in the small time it takes to perform this operation, softirq can
> > queue up to 300 packets coming from the other side.
> 
> There is more to it than just queue-up 16 KB right?

At full rate, we send 825.000 packets per second, and should receive
412.000 ACKS per second if receiver is standard TCP.

The ACK are not smooth, because receiver also have a huge backlog issue
and can send train of ACKS. (I have seen backlogs on receiver using more
than 500 us to be  processed)

If the copyin(16KB) from user to kernel takes some us (preempt,
irqs...), its pretty easy to catch an ACK train in this window.
