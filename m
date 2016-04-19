From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 18:49:20 -0400 (EDT)
Message-ID: <20160419.184920.1193931883675948435.davem@davemloft.net>
References: <20160419.010316.1863885429013017239.davem@davemloft.net>
	<20160419.143134.2014460805657420897.davem@davemloft.net>
	<5716815C.6080601@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, jhs@mojatatu.com,
	tgraf@suug.ch, nicolas.dichtel@6wind.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbcDSWtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 18:49:23 -0400
In-Reply-To: <5716815C.6080601@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Tue, 19 Apr 2016 12:05:00 -0700

> ok, will do. one thing though, for GETSTATS, if I need a pad
> attribute like IFLA_PAD, I will need to add a new stats attribute
> IFLA_STATS_PAD and burn a bit for it in filter_mask too.  In which
> case, I am wondering if we should live with the copy. I will take
> any suggestions here.

I don't think the copy is appropriate, especially if the existing full
link state dump gets away without it.  We're adding this facility for
performance reasons after all.

You have several options to avoid wasting filter mask space. For
example, you could use IFLA_STATS_UNSPEC, which should be OK since
only new applications will use these.

Or you could make IFLA_STATS_PAD the first attribute, and define the
filter mask as relative to it.  Ie. IFLA_STATS_LINK_64 uses bit
(IFLA_STATS_LINK_64 - IFLA_STATS_PAD), etc.
