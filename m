From: David Miller <davem@davemloft.net>
Subject: Re: [SOCK] Avoid integer divides where not necessary in
 include/net/sock.h
Date: Fri, 21 Dec 2007 01:55:43 -0800 (PST)
Message-ID: <20071221.015543.19719154.davem@davemloft.net>
References: <476B5AC0.9060604@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36245
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754694AbXLUJzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 04:55:44 -0500
In-Reply-To: <476B5AC0.9060604@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 21 Dec 2007 07:18:40 +0100

> Because sk_wmem_queued, sk_sndbuf are signed, a divide per two
> forces compiler to use an integer divide. We can instead use
> a right shift.
> 
> SK_STREAM_MEM_QUANTUM deserves to be declared as an unsigned
> quantity, so that sk_stream_pages() and __sk_stream_mem_reclaim()
> can use right shifts instead of integer divides.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Everything that works with SK_STREAM_MEM_QUANTUM is an int.

We do a DIV_ROUND_UP() using SK_STREAM_MEM_QUANTUM and an int.

We do sk->sk_forward_alloc modifications using multiplies on
SK_STREAM_MEM_QUANTUM and an int, sk_forward_alloc is an int
too.

Changing the type of SK_STREAM_MEM_QUANTUM does nothing more than
create an exception in the typing used in these operations for no real
gain, in fact it makes this code's correctness harder to verify.

I'm fine with the rest of your change, so please resubmit this patch
with the type change removed.

Thanks.
