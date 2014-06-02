From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: fix wrong mac_len calculation for vlans
Date: Sun, 01 Jun 2014 19:40:04 -0700 (PDT)
Message-ID: <20140601.194004.1037431819001171433.davem@davemloft.net>
References: <1401293028-18685-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	eric.dumazet@gmail.com, dborkman@redhat.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55556 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753715AbaFBCkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 22:40:05 -0400
In-Reply-To: <1401293028-18685-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Wed, 28 May 2014 18:03:48 +0200

> After 1e785f48d29a ("net: Start with correct mac_len in
> skb_network_protocol") skb->mac_len is used as a start of the
> calculation in skb_network_protocol() but that is not always correct. If
> skb->protocol == 8021Q/AD, usually the vlan header is already inserted
> in the skb (i.e. vlan reorder hdr == 0). Usually when the packet enters
> dev_hard_xmit it has mac_len == 0 so we take 2 bytes from the
> destination mac address (skb->data + VLAN_HLEN) as a type in
> skb_network_protocol() and return vlan_depth == 4. In the case where TSO is
> off, then the mac_len is set but it's == 18 (ETH_HLEN + VLAN_HLEN), so
> skb_network_protocol() returns a type from inside the packet and
> offset == 22. Also make vlan_depth unsigned as suggested before.
> As suggested by Eric Dumazet, move the while() loop in the if() so we
> can avoid additional testing in fast path.
 ...
> CC: Vlad Yasevich <vyasevic@redhat.com>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Daniel Borkman <dborkman@redhat.com>
> CC: David S. Miller <davem@davemloft.net>
> 
> Fixes:1e785f48d29a ("net: Start with correct mac_len in
> skb_network_protocol")
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied, thanks Nikolay.
