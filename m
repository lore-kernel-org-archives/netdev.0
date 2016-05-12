From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: eliminate risk of double link_up
 events
Date: Thu, 12 May 2016 17:12:02 -0400 (EDT)
Message-ID: <20160512.171202.1805015690277237755.davem@davemloft.net>
References: <1463008545-28994-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59679 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466AbcELVMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 17:12:08 -0400
In-Reply-To: <1463008545-28994-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 11 May 2016 19:15:45 -0400

> When an ACTIVATE or data packet is received in a link in state
> ESTABLISHING, the link does not immediately change state to
> ESTABLISHED, but does instead return a LINK_UP event to the caller,
> which will execute the state change in a different lock context.
> 
> This non-atomic approach incurs a low risk that we may have two
> LINK_UP events pending simultaneously for the same link, resulting
> in the final part of the setup procedure being executed twice. The
> only potential harm caused by this it that we may see two LINK_UP
> events issued to subsribers of the topology server, something that
> may cause confusion.
> 
> This commit eliminates this risk by checking if the link is already
> up before proceeding with the second half of the setup.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
