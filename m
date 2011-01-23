From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v4] net-next-2.6: Allow ethtool to set interface in
 loopback mode.
Date: Sun, 23 Jan 2011 12:35:53 +1000
Message-ID: <1295750153.4117.17.camel@localhost>
References: <1294187401-4662-1-git-send-email-maheshb@google.com>
	 <1295655836-23421-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Laurent Chavey <chavey@google.com>,
	netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8904 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252Ab1AWCf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jan 2011 21:35:58 -0500
In-Reply-To: <1295655836-23421-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-01-21 at 16:23 -0800, Mahesh Bandewar wrote:
> This patch enables ethtool to set the loopback mode on a given interface.
> By configuring the interface in loopback mode in conjunction with a policy
> route / rule, a userland application can stress the egress / ingress path
> exposing the flows of the change in progress and potentially help developer(s)
> understand the impact of those changes without even sending a packet out
> on the network.
> 
> Following set of commands illustrates one such example -
> 	a) ip -4 addr add 192.168.1.1/24 dev eth1
> 	b) ip -4 rule add from all iif eth1 lookup 250
> 	c) ip -4 route add local 0/0 dev lo proto kernel scope host table 250
> 	d) arp -Ds 192.168.1.100 eth1
> 	e) arp -Ds 192.168.1.200 eth1
> 	f) sysctl -w net.ipv4.ip_nonlocal_bind=1
> 	g) sysctl -w net.ipv4.conf.all.accept_local=1
> 	# Assuming that the machine has 8 cores
> 	h) taskset 000f netserver -L 192.168.1.200
> 	i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.168.1.200 -l 30
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
[...]

If this version has been revised, you can't claim I reviewed it!
If it's a repost of an earlier version, you should say so.

I thought we agreed that loopback could be treated as a flag, anyway.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

