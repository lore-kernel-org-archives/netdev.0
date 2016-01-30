From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/2] pv6: fix sticky pktinfo behaviour
Date: Fri, 29 Jan 2016 20:31:47 -0800 (PST)
Message-ID: <20160129.203147.89087242679903549.davem@davemloft.net>
References: <cover.1454066754.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
	thehajime@gmail.com, lucien.xin@gmail.com,
	marcelo.leitner@gmail.com, hannes@stressinduktion.org,
	yoshfuji@linux-ipv6.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145AbcA3Ebs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 23:31:48 -0500
In-Reply-To: <cover.1454066754.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Fri, 29 Jan 2016 12:30:18 +0100

> Currently:
> 
> ip addr add dev eth0 2001:0010::1/64
> ip addr add dev eth1 2001:0020::1/64
> ping6 -I eth0 2001:0020::2
> 
> do not lead to the expected results, i.e. eth1 is used as the
> egress interface.
> 
> This is due to two related issues in handling sticky pktinfo,
> used by ping6 to enforce the device binding:
> 
> - ip6_dst_lookup_flow()/ip6_dst_lookup_tail() do not really enforce
> flowi6_oif match
> - ipv6 udp connect() just ignore flowi6_oif
> 
> These patches address each issue individually.
> 
> The kernel has never enforced the egress interface specified
> via the sticky pktinfo, except briefly between the commits
> 741a11d9e410 ("net: ipv6: Add RT6_LOOKUP_F_IFACE flag if oif is set")
> and
> d46a9d678e4c ("net: ipv6: Dont add RT6_LOOKUP_F_IFACE flag if saddr set"),
> but the ping6 tools was unaffected up to iputils-20100214,
> since before it used SO_BINDTODEVICE to enforce the egress
> interface.

Series applied, thanks.
