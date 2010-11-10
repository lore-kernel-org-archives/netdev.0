From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Prevent reading uninitialized memory with socketfilters
Date: Wed, 10 Nov 2010 10:38:07 -0800 (PST)
Message-ID: <20101110.103807.39173013.davem@davemloft.net>
References: <1695276347-1289413089-cardhu_decombobulator_blackberry.rim.net-434693855-@bda083.bisx.prod.on.blackberry>
	<20101110.102129.112602843.davem@davemloft.net>
	<1289414024.2469.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drosenberg@vsecurity.com, netdev@vger.kernel.org,
	stable@kernel.org, security@kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59585
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755143Ab0KJShn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 13:37:43 -0500
In-Reply-To: <1289414024.2469.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 10 Nov 2010 19:33:44 +0100

> Most filters dont use mem[] at all, so the added cost seems OK to me,
> but we can work to use a compile time check, to make memset(mem, 0,
> length) a filter parameter if you prefer removing the test on each
> load(mem[K]).
> 
> This memset() could be avoided if the compiler() can be sure all
> load(mem[K]) follow a prior store(mem[K])
> 
> Its not a five minutes patch, I tried to work on it but it was a bit
> hard, for a very remote security risk.
> 
> (On x86 platform, incoming packets are handled in SOFTIRQ stack, not the
> kernel stack of current thread anyway)

Understood, I'm going to apply your patch for now with the
"const filter pointer" and "u32 f_k = fentry->k;" changes.
