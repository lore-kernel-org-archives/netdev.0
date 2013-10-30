From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Wed, 30 Oct 2013 15:12:25 -0400 (EDT)
Message-ID: <20131030.151225.1564115611396752473.davem@davemloft.net>
References: <1383107681.4857.33.camel@edumazet-glaptop.roam.corp.google.com>
	<20131030044212.GA3364@gondor.apana.org.au>
	<CAPshTCg8j-y6fGfh0tRMir34-Lzy77qyzibvwjMSMpR0Rr1rsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	mwdalton@google.com
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754204Ab3J3TM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 15:12:29 -0400
In-Reply-To: <CAPshTCg8j-y6fGfh0tRMir34-Lzy77qyzibvwjMSMpR0Rr1rsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>
Date: Wed, 30 Oct 2013 10:39:00 -0700

> Not sure I agree - there are two different "forwarding" cases - forwarding
> to another physical NIC (to go out to the wire hence need to do GSO),
> and (for virtualization) forwarding to a virtual NIC and consumed internally
> (e.g., VM). For the latter we should strive to push GSO pkts all the way
> to the VM stack w/o breaking them up. So for virtualization GRO is all
> goodness but not sure about the regular forwarding path. (From the
> perf perspective it boils down to if the cost of GSO/GRO will offset
> the benefit of GRO. Sure if one manages to get the cost close to zero
> than there is not reason to leave GRO always on. But it's still a big if for
> now.)

More precisely, for the regular forwarding path it only needs to be
cheaper than N * cost routing lookup, where N is the number of real
packets contained in the GRO SKB.
