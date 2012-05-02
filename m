From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 3/4 v2 net-next] net: make GRO aware of skb->head_frag
Date: Wed, 02 May 2012 10:02:02 -0700
Message-ID: <4FA1688A.7090200@intel.com>
References: <1335523026.2775.236.camel@edumazet-glaptop>  <1335809434.2296.9.camel@edumazet-glaptop> <4F9F21E2.3080407@intel.com>  <1335835677.11396.5.camel@edumazet-glaptop>  <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>  <1335854378.11396.26.camel@edumazet-glaptop>  <4FA00C9F.8080409@intel.com>  <1335891892.22133.23.camel@edumazet-glaptop>  <4FA03D69.6060907@intel.com>  <1335947084.22133.134.camel@edumazet-glaptop>  <4FA15DDE.5090904@intel.com> <1335975578.22133.580.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	=?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8062 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753607Ab2EBRCD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 13:02:03 -0400
In-Reply-To: <1335975578.22133.580.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2012 09:19 AM, Eric Dumazet wrote:
> On Wed, 2012-05-02 at 09:16 -0700, Alexander Duyck wrote:
>
>> I was working with the out-of-tree ixgbe because I have the option there
>> of stripping out FCoE and RSC via a couple of build flags.  The problem
>> is I don't know if the head frag stuff will work out very well with
>> ixgbe because RSC and FCoE require that we have to use 1K aligned
>> receive buffers.  It would require us to make us have to bump up our
>> allocation size by NET_SKB_PAD plus skb_shared_info which would likely
>> force us up to order 1 pages on most platforms.
> What is RSC exactly, and why RSC is used in the build_skb() context ?
RSC is your in-hardware LRO.  Basically it aggregates the TCP flows in
hardware instead of software.  As a result we have to be able to receive
jumbo frames any time it is enabled.  This means we can end up using the
full data buffer which we can only set in 1K increments.

Thanks,

Alex
