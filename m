From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: nowait parameter.
Date: Fri, 05 Sep 2014 14:26:18 -0700 (PDT)
Message-ID: <20140905.142618.2240630803375505977.davem@davemloft.net>
References: <87oauxibda.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com, minipli@googlemail.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56243 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955AbaIEV0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 17:26:21 -0400
In-Reply-To: <87oauxibda.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed, 03 Sep 2014 13:50:01 +0930

> While trying to measure speed of virtio_net, I was getting hangs.
> This is because we skb_orphan() but delay the tx interrupt
> indefinitely (by number of slots).
> 
> With nowait, pktgen won't wait for the skb to be released.  This
> introduces an error, but it's ok if count >> ringsize.
> 
> I updated the documentation, but it needs far more work (it
> refers to pgset and an examples directory, none of which exist
> in the kernel tree).
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Please just make this a flag, like UDPCSUM, NO_TIMESTAMP, et al.
Which also means that it should be capitalized.

BTW, wrt. holding onto TX frames for unbounded amounts of time, I
think this is a bad idea even with skb_orphan().  There are resources
from the SKB you are hanging onto which can stall the removal of
modules indefinitely, such as netfilter references.
