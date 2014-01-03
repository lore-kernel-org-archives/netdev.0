From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] ipv4: fix tunneled VM traffic over hw VXLAN/GRE
 GSO NIC
Date: Thu, 02 Jan 2014 19:07:43 -0500 (EST)
Message-ID: <20140102.190743.459474382050321416.davem@davemloft.net>
References: <1388092222-4549-1-git-send-email-weichunc@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ast@plumgrid.com, netdev@vger.kernel.org,
	joseph.gasparakis@intel.com, or.gerlitz@gmail.com
To: weichunc@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54560 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753986AbaACAHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 19:07:45 -0500
In-Reply-To: <1388092222-4549-1-git-send-email-weichunc@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei-Chun Chao <weichunc@plumgrid.com>
Date: Thu, 26 Dec 2013 13:10:22 -0800

> VM to VM GSO traffic is broken if it goes through VXLAN or GRE
> tunnel and the physical NIC on the host supports hardware VXLAN/GRE
> GSO offload (e.g. bnx2x and next-gen mlx4).
> 
> Two issues -
> (VXLAN) VM traffic has SKB_GSO_DODGY and SKB_GSO_UDP_TUNNEL with
> SKB_GSO_TCP/UDP set depending on the inner protocol. GSO header
> integrity check fails in udp4_ufo_fragment if inner protocol is
> TCP. Also gso_segs is calculated incorrectly using skb->len that
> includes tunnel header. Fix: robust check should only be applied
> to the inner packet.
> 
> (VXLAN & GRE) Once GSO header integrity check passes, NULL segs
> is returned and the original skb is sent to hardware. However the
> tunnel header is already pulled. Fix: tunnel header needs to be
> restored so that hardware can perform GSO properly on the original
> packet.
> 
> Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>

Applied, thanks.
