From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: allow non-linear first fragment buffer
Date: Wed, 21 Oct 2015 19:09:16 -0700 (PDT)
Message-ID: <20151021.190916.2205639791964404669.davem@davemloft.net>
References: <1445268780-29020-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.xx.bhuvaragan@ericsson.com,
	richard.alpe@ericsson.com, ying.xue@windriver.com,
	maloy@donjonn.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753523AbbJVBwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 21:52:50 -0400
In-Reply-To: <1445268780-29020-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Mon, 19 Oct 2015 11:33:00 -0400

> The current code for message reassembly is erroneously assuming that
> the the first arriving fragment buffer always is linear, and then goes
> ahead resetting the fragment list of that buffer in anticipation of
> more arriving fragments.
> 
> However, if the buffer already happens to be non-linear, we will
> inadvertently drop the already attached fragment list, and later
> on trig a BUG() in __pskb_pull_tail().
> 
> We see this happen when running fragmented TIPC multicast across UDP,
> something made possible since
> commit d0f91938bede ("tipc: add ip/udp media type")
> 
> We fix this by not resetting the fragment list when the buffer is non-
> linear, and by initiatlizing our private fragment list tail pointer to
> the tail of the existing fragment list.
> 
> Fixes: commit d0f91938bede ("tipc: add ip/udp media type")
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied and queued up for -stable, thanks.
