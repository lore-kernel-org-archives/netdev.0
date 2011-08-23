From: David Miller <davem@davemloft.net>
Subject: Re: [net-next,v4 04/12] bna: TX Path and RX Path Changes
Date: Tue, 23 Aug 2011 16:22:20 -0700 (PDT)
Message-ID: <20110823.162220.1108826596231524649.davem@davemloft.net>
References: <1314122168-14314-1-git-send-email-rmody@brocade.com>
	<1314122168-14314-5-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com,
	gkaraje@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754432Ab1HWXXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 19:23:23 -0400
In-Reply-To: <1314122168-14314-5-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 23 Aug 2011 10:56:00 -0700

> +	BNA_QE_INDX_ADD(_index, 1, _depth); \
> +	for (j = 0; j < (_frag); j++) { \
> +		prefetch(&(_array)[(_index) + 1]); \
> +		dma_unmap_page(_pdev, dma_unmap_addr(&(_array)[_index], \

This prefetch is excessive and a waste of cpu cycles.

You're going to prefetch a full 64-byte (or even 128-byte) cache line
for every 16-byte blob (at best) you iterate over.  This means you'll
prefetch the same cache line, needlessly, over and over again.

This is a really terrible patch series, and I'm frankly exhausted from
reviewing it.   I don't want to see another revision of this series for
at least one week.  Read it over carefully, meanwhile.

There is very little thought, and way too much arbitrary tinkering
going on in this driver.
