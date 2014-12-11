From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: Add ability to always enable TSO/UFO
Date: Wed, 10 Dec 2014 21:13:06 -0500 (EST)
Message-ID: <20141210.211306.1331714594864472914.davem@davemloft.net>
References: <1418179394-4470-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<20141210.145047.1148744559031706340.davem@davemloft.net>
	<5488FBBC.2050105@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49577 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933315AbaLKCNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 21:13:11 -0500
In-Reply-To: <5488FBBC.2050105@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Thu, 11 Dec 2014 11:04:44 +0900

> On 2014/12/11 4:50, David Miller wrote:
>> From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>> Date: Wed, 10 Dec 2014 11:43:14 +0900
>> 
>>> -	features &= ~NETIF_F_ONE_FOR_ALL;
>>> +	features &= ~NETIF_F_ONE_FOR_ALL | NETIF_F_GSO_SOFTWARE;
>> 
>> I don't think this is the expression you intend to use.
> 
> Thank you, but this is really my intended expression.
> 
> "features &= ~NETIF_F_ONE_FOR_ALL" drops all of ONE_FOR_ALL bits
> including GSO_SOFTWARE.
> But I want to leave GSO_SOFTWARE bits here.

It is clearer to say this as:

	~(NETIF_F_ONE_FOR_ALL & ~NETIF_F_GSO_SOFTWARE)

Or create a new NETIF_F_* macro to express this idea succinctly.
