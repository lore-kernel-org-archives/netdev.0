From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] be2net: patch set
Date: Fri, 07 Aug 2015 11:57:58 -0700 (PDT)
Message-ID: <20150807.115758.661898041262862547.davem@davemloft.net>
References: <1438759670-2134-1-git-send-email-sathya.perla@avagotech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@avagotech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946186AbbHGS57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 14:57:59 -0400
In-Reply-To: <1438759670-2134-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@avagotech.com>
Date: Wed,  5 Aug 2015 03:27:47 -0400

> This patch set contains 2 driver fixes to a Lancer HW issue and a fix
> to a double free bug. Pls apply to the "net" tree. Thanks!
> 
> Patch 1 now enables filters only after creating RXQs. This is done as 
> HW issues were observed on Lancer adapters if filters
> (flags, mac addrs etc) are enabled *before* creating RXQs. This patch
> changes the driver design by enabling filters in be_open() --
> instead of be_setup() -- after RXQs are created and buffers posted.
> 
> Patch 2 fixes an RX stall issue that was seen on Lancer adapters when
> RXQs are destroyed while they are in an "out of buffer" state.
> This patch fixes this issue by posting 64 buffers to each RXQ before
> destroying them in the close path. This is done after ensuring that no
> more new packets are selected for transfer to the RXQs by disabling
> interface filters.
> 
> Patch 3 protects eqo->affinity_mask variable from being freed twice and
> resulting in a crash.  It's now freed only when EQs haven't yet been
> destroyed.

Series applied, thanks.
