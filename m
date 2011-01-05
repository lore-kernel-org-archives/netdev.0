From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2] net: Allow ethtool to set interface in loopback
 mode.
Date: Tue, 4 Jan 2011 16:36:45 -0800
Message-ID: <20110104163645.0b3a3687@nehalam>
References: <AANLkTikW24AcLEAioYtCwuQOoVnTrqVoAaZw3sksZ_jU@mail.gmail.com>
	<1294187401-4662-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Laurent Chavey <chavey@google.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43715 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641Ab1AEAgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jan 2011 19:36:47 -0500
In-Reply-To: <1294187401-4662-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  4 Jan 2011 16:30:01 -0800
Mahesh Bandewar <maheshb@google.com> wrote:

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

Since this is a boolean it SHOULD go into ethtool_flags rather than
being a high level operation.


-- 
