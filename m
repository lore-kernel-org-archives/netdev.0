From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 2/6] udp: Constify skb argument in lookup
 functions
Date: Tue, 29 Aug 2017 17:58:32 -0700 (PDT)
Message-ID: <20170829.175832.437965683493864458.davem@davemloft.net>
References: <20170829232711.1465-1-tom@quantonium.net>
        <20170829232711.1465-3-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tom@quantonium.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42822 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751378AbdH3A6f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 20:58:35 -0400
In-Reply-To: <20170829232711.1465-3-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@quantonium.net>
Date: Tue, 29 Aug 2017 16:27:07 -0700

> For UDP socket lookup functions, and associateed functions that take an
> skbuf as argument, declare the skb argument as constant.
> 
> One caveat is that reuseport_select_sock can be called from the UDP
> lookup functions with an skb argument. This function temporarily
> modifies the skbuff data pointer (in bpf_run via a pull/push sequence).
> To resolve compiler warning I added a local skbuf declaration that is
> not const and assigned to the skb argument with an explicit cast.
> 
> Signed-off-by: Tom Herbert <tom@quantonium.net>

Please don't do this.

If reuseport_select_sock() modifies anything in the SKB, especially
skb->data, it infects the entire call chain.  So you can't mark it
const in this family of calls.
