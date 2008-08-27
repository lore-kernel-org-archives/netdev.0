From: David Miller <davem@davemloft.net>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Wed, 27 Aug 2008 15:09:55 -0700 (PDT)
Message-ID: <20080827.150955.118944272.davem@davemloft.net>
References: <87zlmyr5nz.fsf@basil.nowhere.org>
	<20080827.142941.50104491.davem@davemloft.net>
	<20080827144800.5f9fc5b4@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, davej@redhat.com, netdev@vger.kernel.org,
	j.w.r.degoede@hhs.nl
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47276
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752249AbYH0WJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 18:09:59 -0400
In-Reply-To: <20080827144800.5f9fc5b4@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 27 Aug 2008 14:48:00 -0700

> I do wonder if having large hash table actually helps? When TCP hash
> table gets too big, it means every lookup is a cache miss. Assuming
> a busy server with 2000 connections and perfect hash. On a 4G mem x86-64
> we are doing 512K hash entries which is ridiculous. Something like 64K
> entries is more than enough.

That's true, but it's nearly guaranteed to only be a single cache miss
at worst (if the hash function is working) compared to potentially
multiple ones if we sized it too small.

I really see the only way to move forward is to dynamically size the
thing.  And nobody has been strong enough to implement that yet :)
