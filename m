From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] pktgen: nowait parameter.
Date: Thu, 11 Sep 2014 09:07:29 +0930
Message-ID: <871trjjbd2.fsf@rustcorp.com.au>
References: <87oauxibda.fsf@rustcorp.com.au> <20140905.142618.2240630803375505977.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, brouer@redhat.com, minipli@googlemail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:43651 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751405AbaIJXqK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 19:46:10 -0400
In-Reply-To: <20140905.142618.2240630803375505977.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Wed, 03 Sep 2014 13:50:01 +0930
>
>> While trying to measure speed of virtio_net, I was getting hangs.
>> This is because we skb_orphan() but delay the tx interrupt
>> indefinitely (by number of slots).
>> 
>> With nowait, pktgen won't wait for the skb to be released.  This
>> introduces an error, but it's ok if count >> ringsize.
>> 
>> I updated the documentation, but it needs far more work (it
>> refers to pgset and an examples directory, none of which exist
>> in the kernel tree).
>> 
>> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
>
> Please just make this a flag, like UDPCSUM, NO_TIMESTAMP, et al.
> Which also means that it should be capitalized.

Agreed, though I prefer Jason's IFF_TX_SKB_FREE_DELAY, which doesn't
require intimate knowledge of the driver to get the option correct.

> BTW, wrt. holding onto TX frames for unbounded amounts of time, I
> think this is a bad idea even with skb_orphan().  There are resources
> from the SKB you are hanging onto which can stall the removal of
> modules indefinitely, such as netfilter references.

We could certainly have a once-a-second timer which did this, but should
skb_orphan() do that work instead?

Cheers,
Rusty.
