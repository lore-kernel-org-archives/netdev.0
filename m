From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Sun, 03 Nov 2013 18:19:48 -0500 (EST)
Message-ID: <20131103.181948.987234612453632341.davem@davemloft.net>
References: <CAPshTCgykFMa=4rnQ3TKa2cfgWYj4TgByO2GbzLzq71Y_=oc=Q@mail.gmail.com>
	<20131029.223331.1745589461091527596.davem@davemloft.net>
	<44571383414236@web13j.yandex.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, herbert@gondor.apana.org.au,
	eric.dumazet@gmail.com, christoph.paasch@uclouvain.be,
	netdev@vger.kernel.org, mwdalton@google.com
To: sysoleg@yandex.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47231 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729Ab3KCXTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Nov 2013 18:19:53 -0500
In-Reply-To: <44571383414236@web13j.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oleg A. Arkhangelsky <sysoleg@yandex.ru>
Date: Sat, 02 Nov 2013 21:43:56 +0400

> 30.10.2013, 06:33, "David Miller" <davem@davemloft.net>:
> 
>> GRO should always win, even on a router, because it decreases the
>> number of fundamental operations (routing lookups) that the stack
>> needs to perform.
> 
> Yes, unless the case when you're using Linux as IP router which is
> forwarding 500K mixed IP (TCP and UDP) flows traffic @ 10-20 Gbit/s.
> Then GRO is unnecessarily overhead, cause there's no possibility to
> accumulate adequate GRO list in such scenario.

If it's not accumulating, then there really isn't much cost because
the bulk of the code paths are short circuited when the flow IDs do
not match.

We touch these packet headers to forward anyways, and that is the bulk
of the cost.
