From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Thu, 04 Jan 2007 12:14:00 +1100
Message-ID: <E1H2HBA-0008L4-00@gondolin.me.apana.org.au>
References: <459C520B.3010406@candelatech.com>
Cc: herbert@gondor.apana.org.au, dlstevens@us.ibm.com, jarkao2@o2.pl,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3879 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932232AbXADBOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 20:14:09 -0500
To: greearb@candelatech.com (Ben Greear)
In-Reply-To: <459C520B.3010406@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> wrote:
> 
> I'm not sure if it helps..but I did notice that 'ip' was using 99% of the
> CPU on the system.  Could this be because it was spinning trying to acquire
> the read-lock?  When I ran 'ifconfig -a', that process hung, and at that point
> the system was rebooted.  Before I ran ifconfig, 'top' and 'ls' and similar
> apps were responding fine, and I was logged in over ssh from the US to Australia, so
> it's basic networking was functioning.

That's understandable because we were stuck in the softirq handler while
holding the rtnl lock.  The rtnl lock is what's preventing those commands
from executing.

What we need to figure out is whether the rtnl lock is a coincidence or
a cause.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
