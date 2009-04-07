From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: fix fragmentation on inter family tunnels
Date: Mon, 06 Apr 2009 17:43:57 -0700 (PDT)
Message-ID: <20090406.174357.85395477.davem@davemloft.net>
References: <20090406135850.GK6791@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47001
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759158AbZDGAoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 20:44:08 -0400
In-Reply-To: <20090406135850.GK6791@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 6 Apr 2009 15:58:50 +0200

> If an ipv4 packet (not locally generated with IP_DF flag not set) bigger
> than mtu size is supposed to go via a xfrm ipv6 tunnel, the packetsize
> check in xfrm4_tunnel_check_size() is omited and ipv6 drops the packet
> without sending a notice to the original sender of the ipv4 packet.
> 
> Another issue is that ipv4 connection tracking does reassembling of
> incomming fragmented packets. If such a reassembled packet is supposed to
> go via a xfrm ipv6 tunnel it will be droped, even if the original sender
> did proper fragmentation.
> 
> According to RFC 2473 (section 7) tunnel ipv6 packets resulting from the
> encapsulation of an original packet are considered as locally generated
> packets. If such a packet passed the checks in xfrm{4,6}_tunnel_check_size()
> fragmentation is allowed according to RFC 2473 (section 7.1/7.2).
> 
> This patch sets skb->local_df in xfrm6_prepare_output() to achieve
> fragmentation in this case.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied, thanks Steffen.
