From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] core/dev: set pkt_type after eth_type_trans() in
 dev_forward_skb()
Date: Tue, 02 Jul 2013 16:00:05 -0700 (PDT)
Message-ID: <20130702.160005.59343488202291094.davem@davemloft.net>
References: <0324dc4a3a7740e4766e16539f4ed41b356f991d.1372764542.git.yamahata@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, murphy.mccauley@gmail.com,
	jasowang@redhat.com, mst@redhat.com, edumazet@google.com,
	kaber@trash.net, honkiko@gmail.com, ramirose@gmail.com,
	tparkin@katalix.com, xiyou.wangcong@gmail.com, pshelar@nicira.com,
	jesse@nicira.com, dev@openvswitch.org
To: yamahata@valinux.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54833 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221Ab3GBXAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 19:00:07 -0400
In-Reply-To: <0324dc4a3a7740e4766e16539f4ed41b356f991d.1372764542.git.yamahata@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue,  2 Jul 2013 20:30:10 +0900

> The dev_forward_skb() assignment of pkt_type should be done
> after the call to eth_type_trans().
> 
> ip-encapsulated packets can be handled by localhost. But skb->pkt_type
> can be PACKET_OTHERHOST when packet comes via veth into ip tunnel device.
> In that case, the packet is dropped by ip_rcv().
> Although this example uses gretap. l2tp-eth also has same issue.
> For l2tp-eth case, add dummy device for ip address and ip l2tp command.
 ...
> Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>

Applied, but I had to adjust the patch because in net-next we use
a new helper function (skb_scrub_packet()) to clear things out from
dev_forward_skb().
