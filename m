From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 01:03:16 -0400 (EDT)
Message-ID: <20160419.010316.1863885429013017239.davem@davemloft.net>
References: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com>
	<20160418.234137.26692086759328024.davem@davemloft.net>
	<1461040324.10638.159.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, nicolas.dichtel@6wind.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58734 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706AbcDSFDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 01:03:18 -0400
In-Reply-To: <1461040324.10638.159.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 18 Apr 2016 21:32:04 -0700

> On Mon, 2016-04-18 at 23:41 -0400, David Miller wrote:
>>  
>> +	/* Add a zero length NOP attribute so that the nla_data()
>> +	 * of the IFLA_STATS64 will be 64-bit aligned.
>> +	 */
>> +#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
>> +	attr = nla_reserve(skb, IFLA_PAD, 0);
>> +	if (!attr)
>> +		return -EMSGSIZE;
>> +#endif
> 
> You must do this only if current skb->data alignment is not correct.

I'll put an assertion there if it makes you happy. :-)
