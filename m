From: David Miller <davem@davemloft.net>
Subject: Re: oops in net/ipv4/icmp.c:icmp_send() with
 icmp_errors_use_inbound_ifaddr (fwd)
Date: Sat, 19 May 2007 14:50:42 -0700 (PDT)
Message-ID: <20070519.145042.105428414.davem@davemloft.net>
References: <4648AE85.6020608@trash.net>
	<4648B656.6030800@trash.net>
	<464C884D.4010100@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmorris@namei.org, Curtis@GreenKey.net
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50576
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758288AbXESVuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2007 17:50:40 -0400
In-Reply-To: <464C884D.4010100@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 17 May 2007 18:52:29 +0200

> [IPV4]: icmp: fix crash with sysctl_icmp_errors_use_inbound_ifaddr
> 
> When icmp_send is called on the local output path before the
> packet hits ip_output, skb->dev is not set, causing a crash
> when sysctl_icmp_errors_use_inbound_ifaddr is set. This can
> happen with the netfilter REJECT target or IPsec tunnels.
> 
> Let routing decide the ICMP source address in that case, since the
> packet is locally generated there is no inbound interface and
> the sysctl should not apply.
> 
> The option actually seems to be unfixable broken, on the path
> after ip_output() skb->dev points to the outgoing device and
> we don't know the incoming device anymore, so its going to do
> the absolute wrong thing and pick the address of the outgoing
> interface. Add a comment about this.
> 
> Reported by Curtis Doty <Curtis@GreenKey.net>.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks for the fix Patrick.

The post ip_output() case is very unfortunate.  Perhaps we
can tag the call sites, or if that doesn't work we can
find some way to perhaps tag the dst as an input vs. output
route in order to avoid this problem.
