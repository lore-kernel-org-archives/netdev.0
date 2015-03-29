From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: fix two bugs in secondary
 destination lookup
Date: Sun, 29 Mar 2015 13:48:29 -0700 (PDT)
Message-ID: <20150329.134829.751362940928175002.davem@davemloft.net>
References: <1427465959-19598-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59714 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752601AbbC2Ujq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 16:39:46 -0400
In-Reply-To: <1427465959-19598-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Fri, 27 Mar 2015 10:19:19 -0400

> A message sent to a node after a successful name table lookup may still
> find that the destination socket has disappeared, because distribution
> of name table updates is non-atomic. If so, the message will be rejected
> back to the sender with error code TIPC_ERR_NO_PORT. If the source
> socket of the message has disappeared in the meantime, the message
> should be dropped.
> 
> However, in the currrent code, the message will instead be subject to an
> unwanted tertiary lookup, because the function tipc_msg_lookup_dest()
> doesn't check if there is an error code present in the message before
> performing the lookup. In the worst case, the message may now find the
> old destination again, and be redirected once more, instead of being
> dropped directly as it should be.
> 
> A second bug in this function is that the "prev_node" field in the message
> is not updated after successful lookup, something that may have
> unpredictable consequences.
> 
> The problems arising from those bugs occur very infrequently.
> 
> The third change in this function; the test on msg_reroute_msg_cnt() is
> purely cosmetic, reflecting that the returned value never can be negative.
> 
> This commit corrects the two bugs described above.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks Jon.
