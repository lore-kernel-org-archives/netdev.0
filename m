From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tipc: fix spinlock recursion bug for failed
 subscriptions
Date: Mon, 24 Mar 2014 15:37:31 -0400 (EDT)
Message-ID: <20140324.153731.470773468265097037.davem@davemloft.net>
References: <1395676598-14928-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, maloy@donjonn.com, ying.xue@windriver.com,
	paul.gortmaker@windriver.com, richard.alpe@ericsson.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754353AbaCXThe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 15:37:34 -0400
In-Reply-To: <1395676598-14928-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Mon, 24 Mar 2014 16:56:38 +0100

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> If a topology event subscription fails for any reason, such as out
> of memory, max number reached or because we received an invalid
> request the correct behavior is to terminate the subscribers
> connection to the topology server. This is currently broken and
> produces the following oops:
 ...
> The recursion occurs when subscr_terminate tries to grab the
> subscriber lock, which is already taken by subscr_conn_msg_event.
> We fix this by checking if the request to establish a new
> subscription was successful, and if not we initiate termination of
> the subscriber after we have released the subscriber lock.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>

Applied and queued up for -stable, thanks!
