From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net] ip_tunnel: Respect the IP_DF bit of the inner
 packet.
Date: Thu, 06 Nov 2014 14:33:51 -0500 (EST)
Message-ID: <20141106.143351.1534959887749218818.davem@davemloft.net>
References: <20141105080930.GE6390@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbaKFTdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 14:33:53 -0500
In-Reply-To: <20141105080930.GE6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 5 Nov 2014 09:09:30 +0100

> The pmtu calculation depends on the IP_DF bit in tnl_update_pmtu().
> If the IP_DF bit is set, the pmtu calculation is based on the outer
> packet size. Otherwise it is based on the inner packet size.
> If xfrm is used after tunneling through an ipip device, the mtu of
> the outer device can be lower than the mtu of the ipip device.
> Reporting the mtu of the ipip device is wrong in this case. So
> respect the IP_DF bit of the inner packet on ipv4 to report the
> calculated mtu of the outer device.
> 
> Fixes: fd58156e456d ("IPIP: Use ip-tunneling code.")
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
> 
> I marked this as RFC because it affects the mtu calculation of
> gre tunnels too. I think it should be ok, but I have no testcase
> to confirm the correctness for gre tunnels. So would be good if
> someone with gre knowlegde could look at this.
> 
> If it turns out that we can't do that for gre, we need to
> split this code back into a gre and an ipip version.

Looking quickly at this, the don't-frag handling in the
pre-ip-tunneling GRE code conversion used different conditions
wrt. calculating 'df'.

It takes the frag off from skb->data's IPH when skb->protocol
is GRE, for example.

So we may have to do this split.
