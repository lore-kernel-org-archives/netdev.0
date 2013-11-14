From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] core/dev: do not ignore dmac in
 dev_forward_skb()
Date: Thu, 14 Nov 2013 02:40:41 -0500 (EST)
Message-ID: <20131114.024041.1374645290667127512.davem@davemloft.net>
References: <1384295953-8332-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org,
	yamahatanetdev@gmail.com, zenczykowski@gmail.com,
	nicolas.dichtel@6wind.com
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab3KNHkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 02:40:43 -0500
In-Reply-To: <1384295953-8332-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 12 Nov 2013 14:39:13 -0800

> commit 06a23fe31ca3
> ("core/dev: set pkt_type after eth_type_trans() in dev_forward_skb()")
> and refactoring 64261f230a91
> ("dev: move skb_scrub_packet() after eth_type_trans()")
> 
> are forcing pkt_type to be PACKET_HOST when skb traverses veth.
> 
> which means that ip forwarding will kick in inside netns
> even if skb->eth->h_dest != dev->dev_addr
> 
> Fix order of eth_type_trans() and skb_scrub_packet() in dev_forward_skb()
> and in ip_tunnel_rcv()
> 
> Fixes: 06a23fe31ca3 ("core/dev: set pkt_type after eth_type_trans() in dev_forward_skb()")
> CC: Isaku Yamahata <yamahatanetdev@gmail.com>
> CC: Maciej Zenczykowski <zenczykowski@gmail.com>
> CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied and queued up for -stable, thanks.
