From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Require exact match for TCP socket lookups if dif
 is l3mdev
Date: Mon, 17 Oct 2016 10:17:30 -0400 (EDT)
Message-ID: <20161017.101730.383079449821386550.davem@davemloft.net>
References: <1476673372-5360-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55748 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758108AbcJQORf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:17:35 -0400
In-Reply-To: <1476673372-5360-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sun, 16 Oct 2016 20:02:52 -0700

> Currently, socket lookups for l3mdev (vrf) use cases can match a socket
> that is bound to a port but not a device (ie., a global socket). If the
> sysctl tcp_l3mdev_accept is not set this leads to ack packets going out
> based on the main table even though the packet came in from an L3 domain.
> The end result is that the connection does not establish creating
> confusion for users since the service is running and a socket shows in
> ss output. Fix by requiring an exact dif to sk_bound_dev_if match if the
> skb came through an interface enslaved to an l3mdev device and the
> tcp_l3mdev_accept is not set.
> 
> skb's through an l3mdev interface are marked by setting a flag in
> inet{6}_skb_parm. The IPv6 variant is already set; this patch adds the
> flag for IPv4. Using an skb flag avoids a device lookup on the dif. The
> flag is set in the VRF driver using the IP{6}CB macros. For IPv4, the
> inet_skb_parm struct is moved in the cb per commit 971f10eca186, so the
> match function in the TCP stack needs to use TCP_SKB_CB. For IPv6, the
> move is done after the socket lookup, so IP6CB is used.
> 
> The flags field in inet_skb_parm struct needs to be increased to add
> another flag. There is currently a 1-byte hole following the flags,
> so it can be expanded to u16 without increasing the size of the struct.
> 
> Fixes: 193125dbd8eb ("net: Introduce VRF device driver")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks David.
