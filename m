From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5 net-next v6] VXLAN Group Policy Extension
Date: Thu, 15 Jan 2015 01:12:55 -0500 (EST)
Message-ID: <20150115.011255.2265998811428735716.davem@davemloft.net>
References: <cover.1421290198.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, stephen@networkplumber.org, pshelar@nicira.com,
	therbert@google.com, alexei.starovoitov@gmail.com,
	nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	dev@openvswitch.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48276 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045AbbAOGM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 01:12:57 -0500
In-Reply-To: <cover.1421290198.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 15 Jan 2015 03:53:54 +0100

> Implements supports for the Group Policy VXLAN extension [0] to provide
> a lightweight and simple security label mechanism across network peers
> based on VXLAN. The security context and associated metadata is mapped
> to/from skb->mark. This allows further mapping to a SELinux context
> using SECMARK, to implement ACLs directly with nftables, iptables, OVS,
> tc, etc.
> 
> The extension is disabled by default and should be run on a distinct
> port in mixed Linux VXLAN VTEP environments. Liberal VXLAN VTEPs
> which ignore unknown reserved bits will be able to receive VXLAN-GBP
> frames.
> 
> Simple usage example:
> 
> 10.1.1.1:
>    # ip link add vxlan0 type vxlan id 10 remote 10.1.1.2 gbp
>    # iptables -I OUTPUT -m owner --uid-owner 101 -j MARK --set-mark 0x200
> 
> 10.1.1.2:
>    # ip link add vxlan0 type vxlan id 10 remote 10.1.1.1 gbp
>    # iptables -I INPUT -m mark --mark 0x200 -j DROP
> 
> iproute2 [1] and OVS [2] support will be provided in separate patches.
> 
> [0] https://tools.ietf.org/html/draft-smith-vxlan-group-policy
> [1] https://github.com/tgraf/iproute2/tree/vxlan-gbp
> [2] https://github.com/tgraf/ovs/tree/vxlan-gbp

Applied, thanks a lot Thomas.
