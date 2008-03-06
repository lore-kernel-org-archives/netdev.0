From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][PPPOL2TP]: Make locking calls softirq-safe
Date: Wed, 05 Mar 2008 18:39:21 -0800 (PST)
Message-ID: <20080305.183921.47316347.davem@davemloft.net>
References: <200803052320.m25NKbr7003898@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@gmail.com
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33655
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753566AbYCFCjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 21:39:22 -0500
In-Reply-To: <200803052320.m25NKbr7003898@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Wed, 5 Mar 2008 23:20:37 GMT

> Fix locking issues in the pppol2tp driver which can cause a kernel
> crash on SMP boxes. There were two problems:-
> 
> 1. The driver was violating read_lock() and write_lock() scheduling
>    rules because it wasn't using softirq-safe locks in softirq
>    contexts. So we now consistently use the _bh variants of the lock
>    functions.
> 
> 2. The driver was calling sk_dst_get() in pppol2tp_xmit() which was
>    taking sk_dst_lock in softirq context. We now call __sk_dst_get().
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>

Applied.
