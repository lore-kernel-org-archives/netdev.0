From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Allow ethtool to set interface in
 loopback mode.
Date: Wed, 27 Apr 2011 23:08:07 -0700 (PDT)
Message-ID: <20110427.230807.48512460.davem@davemloft.net>
References: <1303347458-14499-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57674
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751821Ab1D1GIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 02:08:40 -0400
In-Reply-To: <1303347458-14499-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Wed, 20 Apr 2011 17:57:38 -0700

> This patch enables ethtool to set the loopback mode on a given interface.
> By configuring the interface in loopback mode in conjunction with a policy
> route / rule, a userland application can stress the egress / ingress path
> exposing the flows of the change in progress and potentially help developer(s)
> understand the impact of those changes without even sending a packet out
> on the network.
> 
> Following set of commands illustrates one such example -
>     a) ip -4 addr add 192.168.1.1/24 dev eth1
>     b) ip -4 rule add from all iif eth1 lookup 250
>     c) ip -4 route add local 0/0 dev lo proto kernel scope host table 250
>     d) arp -Ds 192.168.1.100 eth1
>     e) arp -Ds 192.168.1.200 eth1
>     f) sysctl -w net.ipv4.ip_nonlocal_bind=1
>     g) sysctl -w net.ipv4.conf.all.accept_local=1
>     # Assuming that the machine has 8 cores
>     h) taskset 000f netserver -L 192.168.1.200
>     i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.168.1.200 -l 30
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

It's impossible to evaluate this patch without you also showing us some
users.

I'm not applying this.
