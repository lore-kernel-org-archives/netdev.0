From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V3] openvswitch: fix skb_panic due to the incorrect
 actions attrlen
Date: Wed, 16 Aug 2017 14:13:05 -0700 (PDT)
Message-ID: <20170816.141305.1998207836740801812.davem@davemloft.net>
References: <20170816053007.13991-1-zlpnobody@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@ovn.org, netdev@vger.kernel.org, zlpnobody@gmail.com,
        neil.mckee@inmon.com
To: zlpnobody@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38364 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752130AbdHPVNG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 17:13:06 -0400
In-Reply-To: <20170816053007.13991-1-zlpnobody@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@163.com>
Date: Wed, 16 Aug 2017 13:30:07 +0800

> From: Liping Zhang <zlpnobody@gmail.com>
> 
> For sw_flow_actions, the actions_len only represents the kernel part's
> size, and when we dump the actions to the userspace, we will do the
> convertions, so it's true size may become bigger than the actions_len.
> 
> But unfortunately, for OVS_PACKET_ATTR_ACTIONS, we use the actions_len
> to alloc the skbuff, so the user_skb's size may become insufficient and
> oops will happen like this:
 ...
> Also we can find that the actions_len is much little than the orig_len:
>   crash> struct sw_flow_actions 0xffff8812f539d000
>   struct sw_flow_actions {
>     rcu = {
>       next = 0xffff8812f5398800,
>       func = 0xffffe3b00035db32
>     },
>     orig_len = 1384,
>     actions_len = 592,
>     actions = 0xffff8812f539d01c
>   }
> 
> So as a quick fix, use the orig_len instead of the actions_len to alloc
> the user_skb.
> 
> Last, this oops happened on our system running a relative old kernel, but
> the same risk still exists on the mainline, since we use the wrong
> actions_len from the beginning.
> 
> Fixes: ccea74457bbd ("openvswitch: include datapath actions with sampled-packet upcall to userspace")
> Cc: Neil McKee <neil.mckee@inmon.com>
> Signed-off-by: Liping Zhang <zlpnobody@gmail.com>

Applied and queued up for -stable, thanks.
