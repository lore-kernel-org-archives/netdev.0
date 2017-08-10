From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/1] tipc: remove premature ESTABLISH FSM event at link
 synchronization
Date: Wed, 09 Aug 2017 22:38:50 -0700 (PDT)
Message-ID: <20170809.223850.1304726785328764444.davem@davemloft.net>
References: <1502223836-3182-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parthasarathy.bhuvaragan@ericsson.com,
        ying.xue@windriver.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51794 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750837AbdHJFiv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 01:38:51 -0400
In-Reply-To: <1502223836-3182-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Tue, 8 Aug 2017 22:23:56 +0200

> When a link between two nodes come up, both endpoints will initially
> send out a STATE message to the peer, to increase the probability that
> the peer endpoint also is up when the first traffic message arrives.
> Thereafter, if the establishing link is the second link between two
> nodes, this first "traffic" message is a TUNNEL_PROTOCOL/SYNCH message,
> helping the peer to perform initial synchronization between the two
> links.
> 
> However, the initial STATE message may be lost, in which case the SYNCH
> message will be the first one arriving at the peer. This should also
> work, as the SYNCH message itself will be used to take up the link
> endpoint before  initializing synchronization.
> 
> Unfortunately the code for this case is broken. Currently, the link is
> brought up through a tipc_link_fsm_evt(ESTABLISHED) when a SYNCH
> arrives, whereupon __tipc_node_link_up() is called to distribute the
> link slots and take the link into traffic. But, __tipc_node_link_up() is
> itself starting with a test for whether the link is up, and if true,
> returns without action. Clearly, the tipc_link_fsm_evt(ESTABLISHED) call
> is unnecessary, since tipc_node_link_up() is itself issuing such an
> event, but also harmful, since it inhibits tipc_node_link_up() to
> perform the test of its tasks, and the link endpoint in question hence
> is never taken into traffic.
> 
> This problem has been exposed when we set up dual links between pre-
> and post-4.4 kernels, because the former ones don't send out the
> initial STATE message described above.
> 
> We fix this by removing the unnecessary event call.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
