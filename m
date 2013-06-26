From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] loopback: set pkt_type to PACKET_HOST explicitly
Date: Wed, 26 Jun 2013 15:29:30 -0700 (PDT)
Message-ID: <20130626.152930.1401552744929449732.davem@davemloft.net>
References: <0cd1047a2432736459fabbe97a8fb81c449fd827.1372232028.git.yamahata@valinux.co.jp>
	<1372236022.3301.128.camel@edumazet-glaptop>
	<20130626093751.GB8524@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	murphy.mccauley@gmail.com, pshelar@nicira.com, jesse@nicira.com,
	dev@openvswitch.org
To: yamahata@valinux.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281Ab3FZW3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 18:29:31 -0400
In-Reply-To: <20130626093751.GB8524@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 26 Jun 2013 18:37:51 +0900

> veth does. vethb-peer in the above example.
> (veth_xmit() -> dev_forward_skb() -> eth_type_trans())
> The destination mac address of arp reply is set to the one of
> vetha (!= vethb-peer). So vethb-peer sets pkt_type to OTHERHOST.
> bridge and gretap doesn't touch skb->pkt_type.

I think the dev_forward_skb() assignment of pkt_type should be done
after the call to eth_type_trans().

That's the whole point, we know we're looping the packet back to a
local device on this host.

I'm not applying this loopback patch, sorry.
