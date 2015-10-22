From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipvlan: read direct ifindex instead of iflink
Date: Thu, 22 Oct 2015 06:39:35 -0700 (PDT)
Message-ID: <20151022.063935.2080435401442263071.davem@davemloft.net>
References: <20151020234732.GA16302@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com
To: bblanco@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53977 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757629AbbJVNXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 09:23:08 -0400
In-Reply-To: <20151020234732.GA16302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brenden Blanco <bblanco@plumgrid.com>
Date: Tue, 20 Oct 2015 16:47:33 -0700

> In the ipv4 outbound path of an ipvlan device in l3 mode, the ifindex is
> being grabbed from dev_get_iflink. This works for the physical device
> case, since as the documentation of that function notes: "Physical
> interfaces have the same 'ifindex' and 'iflink' values.".  However, if
> the master device is a veth, and the pairs are in separate net
> namespaces, the route lookup will fail with -ENODEV due to outer veth
> pair being in a separate namespace from the ipvlan master/routing
> namespace.
> 
>   ns0    |   ns1    |   ns2
>  veth0a--|--veth0b--|--ipvl0
> 
> In ipvlan_process_v4_outbound(), a packet sent from ipvl0 in the above
> configuration will pass fl.flowi4_oif == veth0a to
> ip_route_output_flow(), but *net == ns1.
> 
> Notice also that ipv6 processing is not using iflink. Since there is a
> discrepancy in usage, fixup both v4 and v6 case to use local dev
> variable.
> 
> Tested this with l3 ipvlan on top of veth, as well as with single
> physical interface in the top namespace.
> 
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>

Applied, thanks Brenden.
