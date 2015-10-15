From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/1] tipc: move fragment importance field to new
 header position
Date: Wed, 14 Oct 2015 19:11:35 -0700 (PDT)
Message-ID: <20151014.191135.1219624262492465710.davem@davemloft.net>
References: <1444828998-2078-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.xx.bhuvaragan@ericsson.com,
	richard.alpe@ericsson.com, ying.xue@windriver.com,
	maloy@donjonn.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38301 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430AbbJOBzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 21:55:31 -0400
In-Reply-To: <1444828998-2078-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 14 Oct 2015 09:23:18 -0400

> In commit e3eea1eb47a ("tipc: clean up handling of message priorities")
> we introduced a field in the packet header for keeping track of the
> priority of fragments, since this value is not present in the specified
> protocol header. Since the value so far only is used at the transmitting
> end of the link, we have not yet officially defined it as part of the
> protocol.
> 
> Unfortunately, the field we use for keeping this value, bits 13-15 in
> in word 5, has turned out to be a poor choice; it is already used by the
> broadcast protocol for carrying the 'network id' field of the sending
> node. Since packet fragments also need to be transported across the
> broadcast protocol, the risk of conflict is obvious, and we see this
> happen when we use network identities larger than 2^13-1. This has
> escaped our testing because we have so far only been using small network
> id values.
> 
> We now move this field to bits 0-2 in word 9, a field that is guaranteed
> to be unused by all involved protocols.
> 
> Fixes: e3eea1eb47a ("tipc: clean up handling of message priorities")
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> Acked-by: Ying Xue <ying.xue@windriver.com>

Applied and queued up for -stable, thanks.
