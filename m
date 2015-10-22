From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: conditionally expand buffer headroom
 over udp tunnel
Date: Wed, 21 Oct 2015 19:14:23 -0700 (PDT)
Message-ID: <20151021.191423.791280620669017040.davem@davemloft.net>
References: <1445269391-30333-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.xx.bhuvaragan@ericsson.com,
	richard.alpe@ericsson.com, ying.xue@windriver.com,
	maloy@donjonn.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49875 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755879AbbJVB56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 21:57:58 -0400
In-Reply-To: <1445269391-30333-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Mon, 19 Oct 2015 11:43:11 -0400

> In commit d999297c3dbbe ("tipc: reduce locking scope during packet reception")
> we altered the packet retransmission function. Since then, when
> restransmitting packets, we create a clone of the original buffer
> using __pskb_copy(skb, MIN_H_SIZE), where MIN_H_SIZE is the size of
> the area we want to have copied, but also the smallest possible TIPC
> packet size. The value of MIN_H_SIZE is 24.
> 
> Unfortunately, __pskb_copy() also has the effect that the headroom
> of the cloned buffer takes the size MIN_H_SIZE. This is too small
> for carrying the packet over the UDP tunnel bearer, which requires
> a minimum headroom of 28 bytes. A change to just use pskb_copy()
> lets the clone inherit the original headroom of 80 bytes, but also
> assumes that the copied data area is of at least that size, something
> that is not always the case. So that is not a viable solution.
> 
> We now fix this by adding a check for sufficient headroom in the
> transmit function of udp_media.c, and expanding it when necessary.
> 
> Fixes: commit d999297c3dbbe ("tipc: reduce locking scope during packet reception")
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
