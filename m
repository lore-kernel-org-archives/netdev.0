From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] vxlan: fix ND proxy when skb doesn't have
 transport header offset
Date: Mon, 03 Apr 2017 18:51:48 -0700 (PDT)
Message-ID: <20170403.185148.955031362401899474.davem@davemloft.net>
References: <201704020408.cWbCLxF2%fengguang.wu@intel.com>
        <20170402090006.17545-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, roopa@cumulusnetworks.com, jbenc@redhat.com,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: vincent@bernat.im
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53072 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751362AbdDDBvu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 21:51:50 -0400
In-Reply-To: <20170402090006.17545-1-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Bernat <vincent@bernat.im>
Date: Sun,  2 Apr 2017 11:00:06 +0200

> When an incoming frame is tagged or when GRO is disabled, the skb
> handled to vxlan_xmit() doesn't contain a valid transport header
> offset. This makes ND proxying fail.
> 
> We combine two changes: replace use of skb_transport_offset() and ensure
> the necessary amount of skb is linear just before using it:
> 
>  - In vxlan_xmit(), when determining if we have an ICMPv6 neighbor
>    discovery packet, just check if it is an ICMPv6 packet and rely on
>    neigh_reduce() to do more checks if this is the case. The use of
>    pskb_may_pull() is replaced by skb_header_pointer() for just the IPv6
>    header.
> 
>  - In neigh_reduce(), add pskb_may_pull() for IPv6 header and neighbor
>    discovery message since this was removed from vxlan_xmit(). Replace
>    skb_transport_header() with ipv6_hdr() + 1.
> 
>  - In vxlan_na_create(), replace first skb_transport_offset() with
>    ipv6_hdr() + 1 and second with skb_network_offset() + sizeof(struct
>    ipv6hdr). Additionally, ensure we pskb_may_pull() the whole skb as we
>    need it to iterate over the options.
> 
> Signed-off-by: Vincent Bernat <vincent@bernat.im>

Applied, thanks.
