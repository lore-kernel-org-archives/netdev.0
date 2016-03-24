From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 2/2] net: bcmgenet: fix skb_len in
 bcmgenet_xmit_single()
Date: Thu, 24 Mar 2016 15:15:25 -0400 (EDT)
Message-ID: <20160324.151525.658998179104675344.davem@davemloft.net>
References: <1458844041-71532-1-git-send-email-pgynther@google.com>
	<1458844041-71532-2-git-send-email-pgynther@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	jaedon.shin@gmail.com, edumazet@google.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbcCXTP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 15:15:26 -0400
In-Reply-To: <1458844041-71532-2-git-send-email-pgynther@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Thu, 24 Mar 2016 11:27:21 -0700

> skb_len needs to be skb_headlen(skb) in bcmgenet_xmit_single().
> 
> Fragmented skbs can have only Ethernet + IP + TCP headers (14+20+20=54 bytes)
> in the linear buffer, followed by the rest in fragments. Bumping skb_len to
> ETH_ZLEN would be incorrect for this case, as it would introduce garbage
> between TCP header and the fragment data.
> 
> This also works with regular/non-fragmented small packets < ETH_ZLEN bytes.
> Successfully tested this on GENETv3 with 42-byte ARP frames.
> 
> For testing, I used:
> ethtool -K eth0 tx-checksum-ipv4 off
> ethtool -K eth0 tx-checksum-ipv6 off
> echo 0 > /proc/sys/net/ipv4/tcp_timestamps
> 
> Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
> Signed-off-by: Petri Gynther <pgynther@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
