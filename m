From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Lookup actual route when oif is VRF
 device
Date: Wed, 07 Oct 2015 04:31:40 -0700 (PDT)
Message-ID: <20151007.043140.2292153680902956363.davem@davemloft.net>
References: <1444067344-31144-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52948 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753598AbbJGLP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 07:15:56 -0400
In-Reply-To: <1444067344-31144-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon,  5 Oct 2015 10:49:04 -0700

> If the user specifies a VRF device in a get route query the custom route
> pointing to the VRF device is returned:
> 
>     $ ip route ls table vrf-red
>     unreachable default
>     broadcast 10.2.1.0 dev eth1  proto kernel  scope link  src 10.2.1.2
>     10.2.1.0/24 dev eth1  proto kernel  scope link  src 10.2.1.2
>     local 10.2.1.2 dev eth1  proto kernel  scope host  src 10.2.1.2
>     broadcast 10.2.1.255 dev eth1  proto kernel  scope link  src 10.2.1.2
> 
>     $ ip route get oif vrf-red 10.2.1.40
>     10.2.1.40 dev vrf-red
>         cache
> 
> Add the flags to skip the custom route and go directly to the FIB. With
> this patch the actual route is returned:
> 
>     $ ip route get oif vrf-red 10.2.1.40
>     10.2.1.40 dev eth1  src 10.2.1.2
>         cache
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thank
