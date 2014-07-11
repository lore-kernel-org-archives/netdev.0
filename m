From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: clear 'next'-pointer of message
 fragments before reassembly
Date: Fri, 11 Jul 2014 15:03:26 -0700 (PDT)
Message-ID: <20140711.150326.1909630456081646584.davem@davemloft.net>
References: <1405082727-14546-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263AbaGKWD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 18:03:27 -0400
In-Reply-To: <1405082727-14546-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Fri, 11 Jul 2014 08:45:27 -0400

> If the 'next' pointer of the last fragment buffer in a message is not
> zeroed before reassembly, we risk ending up with a corrupt message,
> since the reassembly function itself isn't doing this.
> 
> Currently, when a buffer is retrieved from the deferred queue of the
> broadcast link, the next pointer is not cleared, with the result as
> described above.
> 
> This commit corrects this, and thereby fixes a bug that may occur when
> long broadcast messages are transmitted across dual interfaces. The bug
> has been present since 40ba3cdf542a469aaa9083fa041656e59b109b90 ("tipc:
> message reassembly using fragment chain")
> 
> This commit should be applied to both net and net-next.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, but I have to say this isn't the first time I've seen the TIPC
buffer chaining code require a bug fix like this.

That gives me the impression that it's done in an error prone way, so
you may want to take that into consideration and do something to make
these lists harder to mismanage.

Thanks.
