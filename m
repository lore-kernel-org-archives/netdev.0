From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Do not drop to make_route if oif is
 l3mdev
Date: Thu, 08 Oct 2015 05:19:17 -0700 (PDT)
Message-ID: <20151008.051917.144727775838115455.davem@davemloft.net>
References: <1444232413-8435-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32819 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756014AbbJHMD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 08:03:29 -0400
In-Reply-To: <1444232413-8435-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed,  7 Oct 2015 08:40:13 -0700

> Commit deaa0a6a930 ("net: Lookup actual route when oif is VRF device")
> exposed a bug in __ip_route_output_key_hash for VRF devices: on FIB lookup
> failure if the oif is specified the current logic drops to make_route on
> the assumption that the route tables are wrong. For VRF/L3 master devices
> this leads to wrong dst entries and route lookups. For example:
>     $ ip route ls table vrf-red
>     unreachable default
>     broadcast 10.2.1.0 dev eth1  proto kernel  scope link  src 10.2.1.2
>     10.2.1.0/24 dev eth1  proto kernel  scope link  src 10.2.1.2
>     local 10.2.1.2 dev eth1  proto kernel  scope host  src 10.2.1.2
>     broadcast 10.2.1.255 dev eth1  proto kernel  scope link  src 10.2.1.2
> 
>     $ ip route get oif vrf-red 1.1.1.1
>     1.1.1.1 dev vrf-red  src 10.0.0.2
>         cache
> 
> With this patch:
>     $  ip route get oif vrf-red 1.1.1.1
>     RTNETLINK answers: No route to host
> 
> which is the correct response based on the default route
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks.
