From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/9] net: Remove e_inval label from
 ip_route_input_slow
Date: Wed, 23 Sep 2015 11:14:36 -0700 (PDT)
Message-ID: <20150923.111436.160207282585511690.davem@davemloft.net>
References: <5602C901.2050404@gmail.com>
	<5602CD17.3030008@cumulusnetworks.com>
	<5602D3CA.7010502@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813AbbIWSOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 14:14:38 -0400
In-Reply-To: <5602D3CA.7010502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 23 Sep 2015 09:31:06 -0700

> It is the general direction of this I don't like since it is just
> making the code uglier before you attempt to fix it.

I agree, I don't like these refactorings at all.

Some of these code paths have been this way for a decade or longer,
and are etched into the back of our skulls.

Unless there is _true_ benefit, just leave the code alone, really.

I also really don't like "un-goto" conversions at all, they generally
make the code harder to read.  And as Eric Dumazet said, unless you
carefully pair such changes with appropriate likely()/unlikely()
taggin you pessimize the code.
