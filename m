From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Could we avoid touching dst->refcount in some cases ?
Date: Mon, 24 Nov 2008 15:39:54 -0800 (PST)
Message-ID: <20081124.153954.215777060.davem@davemloft.net>
References: <492A6C94.7030308@cosmosbay.com>
	<87y6z9h33h.fsf@basil.nowhere.org>
	<492A7E85.3060502@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59177
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753559AbYKXXjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 18:39:54 -0500
In-Reply-To: <492A7E85.3060502@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 24 Nov 2008 11:14:29 +0100

> So maybe we could make ip_append_data() (or its callers) a
> litle bit smarter, avoiding increment/decrement if possible.

These ideas are interesting but hard to make work.

I think the receive path has more chance of getting gains
from this, to be honest.

One third (effectively) of TCP stream packets are ACKs and
freed immediately.  This means that the looked up route does
not escape the packet receive path.  So we could elide the
counter increment in that case.

In fact, once we queue even TCP data, there is no need for
that cached skb->dst route any longer.

So pretty much all TCP packets could avoid the dst refcounting
on receive.
