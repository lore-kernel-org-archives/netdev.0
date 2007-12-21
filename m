From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 2/4] [CORE]: datagram: basic memory accounting functions
Date: Thu, 20 Dec 2007 23:18:54 -0500
Message-ID: <476B3EAE.4070809@redhat.com>
References: <47673195.80004@redhat.com>	<47673299.3010301@redhat.com> <20071220.034304.212231150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	tyasui@redhat.com, mhiramat@redhat.com,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com, haoki@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56428 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751157AbXLUEU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 23:20:58 -0500
In-Reply-To: <20071220.034304.212231150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Thank you so much for your comments.

David Miller wrote:

> All of these other functions are identical copies of the stream
> counterparts, they should all be consolidated.
> 
> I still see a lot of special casing, instead of large pieces of common
> code.
> 
> There should be one core set of functions that handle the memory
> accounting, regardless of socket type.  Maybe there is one spot where
> something like sk->prot->doing_memory_accounting is tested, but that's
> it.

I understood. I'll re-write my patch set to make memory accounting
core functions.

> Also, the memory accounting is done at different parts in
> the socket code paths for stream vs. datagram.  This is why
> everything is inconsistent, and, a mess.

Could you tell me more detailed information?

Does this comment mean interface and usage of memory accounting functions?
If so, I'll consolidate functions like sk_stream_set_owner_r() and
sk_stream_free_skb(). And, I may have to use memory accounting functions in
memory allocating functions like sk_stream_alloc_pskb() as possible
instead of inside of socket operating functions.

Or, does the comment mean that send buffer accounting in IP layer
(e.g. ip_append_data()) is wrong?

Anyway, in next patch set, I'm going to consolidate mem_schedule
functions and mem_reclaim functions. To do so, some of memory
accounting functions for stream protocols will be renamed or
be moved to core/sock.c from core/stream.c.

I would like to know what kind of enhancement must be needed for
memory accounting core functions.

Again, thank you for taking your time to review this feature.

Best regards,
Hideo

-- 
Hitachi Computer Products (America) Inc.
