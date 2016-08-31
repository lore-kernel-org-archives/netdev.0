From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Don't unset flowi6_proto in ipxip6_tnl_xmit()
Date: Wed, 31 Aug 2016 13:56:03 -0700 (PDT)
Message-ID: <20160831.135603.430800022553448126.davem@davemloft.net>
References: <20160826155229.8040-1-elicooper@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: elicooper@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48298 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761072AbcHaU4I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 16:56:08 -0400
In-Reply-To: <20160826155229.8040-1-elicooper@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cooper <elicooper@gmx.com>
Date: Fri, 26 Aug 2016 23:52:29 +0800

> @@ -1174,6 +1174,7 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
>  		encap_limit = t->parms.encap_limit;
>  
>  	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
> +	fl6.flowi6_proto = IPPROTO_IPIP;

Let's just simply have t->fl have the proto setup properly, just like
in GRE.

Assigning it explicitly every packet transmit doesn't make much sense.
