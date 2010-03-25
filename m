From: Patrick McHardy <kaber@trash.net>
Subject: Re: debugging kernel during packet drops
Date: Thu, 25 Mar 2010 11:35:55 +0100
Message-ID: <4BAB3C8B.3030104@trash.net>
References: <4BA74950.6000305@infopact.nl> <4BA7A5D8.5080101@trash.net>	 <4BA8DAC5.6050002@infopact.nl> <1269364893.2983.296.camel@edumazet-laptop>	 <4BAA2DC5.7000409@infopact.nl>  <1269447674.3213.64.camel@edumazet-laptop> <1269509574.3626.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jorrit Kronjee <j.kronjee@infopact.nl>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48705 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753999Ab0CYKfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 06:35:55 -0400
In-Reply-To: <1269509574.3626.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Here is patch I cooked for xt_hashlimit (on top of net-next-2.6) to make
> it use RCU and scale better in your case (allowing several concurrent
> cpus once RPS is activated), but also on more general cases.
> 
> [PATCH] xt_hashlimit: RCU conversion
> 
> xt_hashlimit uses a central lock per hash table and suffers from
> contention on some workloads.
> 
> After RCU conversion, central lock is only used when a writer wants to
> add or delete an entry. For 'readers', updating an existing entry, they
> use an individual lock per entry.

This clashes with some recent cleanups in nf-next-2.6.git. I'm
also expecting a patch from Jan to remove the old v0 revision
very soon (probably today). Please rediff once I've pushed that out.
