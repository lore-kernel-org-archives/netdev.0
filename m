From: David Miller <davem@davemloft.net>
Subject: Re: Multicast packet loss
Date: Sun, 08 Mar 2009 19:49:22 -0700 (PDT)
Message-ID: <20090308.194922.267426196.davem@davemloft.net>
References: <49AE3DA9.2020103@cosmosbay.com>
	<49B2266C.9050701@cosmosbay.com>
	<49B3F655.6030308@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kchang@athenacr.com, netdev@vger.kernel.org,
	cl@linux-foundation.org, bmb@athenacr.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56009
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753093AbZCICtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2009 22:49:36 -0400
In-Reply-To: <49B3F655.6030308@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sun, 08 Mar 2009 17:46:13 +0100

> +	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep)) {
> +		if (in_softirq()) {
> +			if (!softirq_del(&sk->sk_del, sock_readable_defer))
> +				goto unlock;
> +			return;
> +		}

This is interesting.

I think you should make softirq_del() more flexible.  Make it the
socket's job to make sure it doesn't try to defer different
functions, and put the onus on locking there as well.

The cmpxchg() and all of this checking is just wasted work.

I'd really like to get rid of that callback lock too, then we'd
really be in business. :-)

