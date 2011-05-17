From: Andi Kleen <andi@firstfloor.org>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 14:44:42 -0700
Message-ID: <m2aaelypbp.fsf@firstfloor.org>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	<1305663288.2691.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7338 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932308Ab1EQVpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 17:45:13 -0400
In-Reply-To: <1305663288.2691.2.camel@edumazet-laptop> (Eric Dumazet's message
	of "Tue, 17 May 2011 22:14:48 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
>
> OK but do we have workloads actually needing this optimization at all ?

That's a good a question.
>
> (IP defrag hits a read_lock(&ip4_frags.lock)), so maybe steer all frags
> on a given cpu ?)

Couldn't the lock just be replaced with a hashed or bitmap lock or 
bit in low bits of pointer lock?

iirc it just protects the heads of the hash table.

They're not rwlocks, but especially if the locking was more finegrained
that's likely not needed anymore.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
