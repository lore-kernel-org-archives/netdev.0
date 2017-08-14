From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/1] tipc: avoid inheriting msg_non_seq flag when message
 is returned
Date: Mon, 14 Aug 2017 11:20:53 -0700 (PDT)
Message-ID: <20170814.112053.618707344690020434.davem@davemloft.net>
References: <1502728129-10537-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parthasarathy.bhuvaragan@ericsson.com,
        ying.xue@windriver.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38886 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751365AbdHNSUy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 14:20:54 -0400
In-Reply-To: <1502728129-10537-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Mon, 14 Aug 2017 18:28:49 +0200

> In the function msg_reverse(), we reverse the header while trying to
> reuse the original buffer whenever possible. Those rejected/returned
> messages are always transmitted as unicast, but the msg_non_seq field
> is not explicitly set to zero as it should be.
> 
> We have seen cases where multicast senders set the message type to
> "NOT dest_droppable", meaning that a multicast message shorter than
> one MTU will be returned, e.g., during receive buffer overflow, by
> reusing the original buffer. This has the effect that even the
> 'msg_non_seq' field is inadvertently inherited by the rejected message,
> although it is now sent as a unicast message. This again leads the
> receiving unicast link endpoint to steer the packet toward the broadcast
> link receive function, where it is dropped. The affected unicast link is
> thereafter (after 100 failed retransmissions) declared 'stale' and
> reset.
> 
> We fix this by unconditionally setting the 'msg_non_seq' flag to zero
> for all rejected/returned messages.
> 
> Reported-by: Canh Duc Luu <canh.d.luu@dektech.com.au>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Also applied, thanks again.
