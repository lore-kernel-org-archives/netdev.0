From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 3/3] Uninline the inet_twsk_put function
Date: Thu, 20 Dec 2007 16:08:40 -0800 (PST)
Message-ID: <20071220.160840.140150524.davem@davemloft.net>
References: <4768F8CD.2050209@openvz.org>
	<200712201932.45900.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: netdev@axxeo.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52284
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754119AbXLUAIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 19:08:41 -0500
In-Reply-To: <200712201932.45900.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Oeser <netdev@axxeo.de>
Date: Thu, 20 Dec 2007 19:32:45 +0100

> static inline inet_twsk_put(struct inet_timewait_sock *tw)
> {
> 	kref_put(&tw->kref, inet_twsk_release);
> }
> 
> David, can you see any reason (e.g. some crazy lock stuff) NOT to do this?

Look at how this datastructure actually works before making
such suggestions, don't just look at the context provided
purely by a patch.

"inet_timewait_sock" begins with a "struct sock_common"
which is where the atomic_t is, and:

#define tw_refcnt		__tw_common.skc_refcnt

So you would have to change struct sock_common over to kref, and thus
the entire networking, in order to make such a change.

I see zero value in this.  There are millions of more useful things to
invest that kind of time on.

But you would have seen this instantly if you had spent 5 seconds
looking at how these datastructures are defined.  Instead you choose
to make me do it and explain it to you instead.
