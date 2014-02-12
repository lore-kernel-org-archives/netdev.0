From: David Miller <davem@davemloft.net>
Subject: Re: NETIF_F_HIGHDMA?
Date: Wed, 12 Feb 2014 17:51:54 -0500 (EST)
Message-ID: <20140212.175154.969884304002436752.davem@davemloft.net>
References: <52FBFD03.6000703@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284AbaBLWv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:51:56 -0500
In-Reply-To: <52FBFD03.6000703@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 13 Feb 2014 02:00:19 +0300

> Hello.
> 
>    I fail to understand why this flag is needed at
>    all. netdev-features.txt says:
> 
>  * Transmit DMA from high memory
> 
> On platforms where this is relevant, NETIF_F_HIGHDMA signals that
> ndo_start_xmit can handle skbs with frags in high memory.

Back when this flag was created we had pretty much no infrastructure
to deal with DMA masks, and furthermore it was not universal that
code accessed high memory pages correctly.

So this was the hack we used, the flag meant that your driver was
able to access high memory pages correctly (ie. didn't assume that
all pages were identity mapped) and that you could handle pages
that potentially had physical addresses above 4GB.

It was a big hammer handling a lack of proper APIs, that's all.
