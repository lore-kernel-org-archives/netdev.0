From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next-2.6] r8169: add gro support
Date: Tue, 7 Sep 2010 22:24:45 +0200
Message-ID: <20100907202445.GA11841@electric-eye.fr.zoreil.com>
References: <1283834799.2585.476.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 217.59.140-88.rev.gaoland.net ([88.140.59.217]:57419 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756829Ab0IGUZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 16:25:19 -0400
Content-Disposition: inline
In-Reply-To: <1283834799.2585.476.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> :
> - Use napi_gro_receive() and vlan_gro_receive()
> - Enable GRO by default
> 
> Tested on a RTL8111/8168 adapter
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Francois Romieu <romieu@fr.zoreil.com>
[...]
> @@ -1076,7 +1076,12 @@ static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
>  	int ret;
>  
>  	if (vlgrp && (opts2 & RxVlanTag)) {
> -		__vlan_hwaccel_rx(skb, vlgrp, swab16(opts2 & 0xffff), polling);
> +		u16 vtag = swab16(opts2 & 0xffff);
> +
> +		if (polling)

		if (likely(polling))

Otherwise Acked-by: Francois Romieu <romieu@fr.zoreil.com>

-- 
Ueimor
