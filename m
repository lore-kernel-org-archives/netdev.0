From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/5] net-timestamp: extend SCM_TIMESTAMPING
 ancillary data struct
Date: Wed, 23 Jul 2014 21:12:56 -0700 (PDT)
Message-ID: <20140723.211256.2143360320648788946.davem@davemloft.net>
References: <1405971357-22830-2-git-send-email-willemb@google.com>
	<20140721.162448.2136956416390069389.davem@davemloft.net>
	<CA+FuTScobCk5EFgsht=S0mfF4fVh1fKqAAV8+mZLk9h1O_uwnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40460 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbaGXEM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 00:12:58 -0400
In-Reply-To: <CA+FuTScobCk5EFgsht=S0mfF4fVh1fKqAAV8+mZLk9h1O_uwnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Tue, 22 Jul 2014 11:45:30 -0400

> There are a few alternatives, but none as simple, so this is better
> left to a separate patch. With skb_shinfo(skb)->syststamp deprecated
> for all but the octeon legacy use case, it is possible to repurpose
> those bytes for new uses in a union, including for a new u16 ts_key.
> The sk would still have to grow by a new field, though, e.g.,
> ts_counter. I have to think about this a bit more first.

I can't believe we're going to hold onto syststamp just for one
odd-ball MIPS ethernet driver.  Really?

I think putting in whatever work is necessary to convert Octeon over
to exposing a proper PTP device is much better than having this
syststamp thing rot in our data structures forever.
