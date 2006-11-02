From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 6/6] IPv6: Fix infinite loop if no matching IPv6 tunnel
 found
Date: Thu, 02 Nov 2006 21:59:00 +0900 (JST)
Message-ID: <20061102.215900.15793371.yoshfuji@linux-ipv6.org>
References: <4549D8E7.1040409@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:523 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1752129AbWKBM4M
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 07:56:12 -0500
To: vnuorval@tcs.hut.fi
In-Reply-To: <4549D8E7.1040409@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <4549D8E7.1040409@tcs.hut.fi> (at Thu, 02 Nov 2006 13:39:19 +0200), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

>  	read_unlock(&ip6ip6_lock);
> -	return 1;
> -
> +	icmpv6_send(skb, ICMPV6_DEST_UNREACH,
> +		    ICMPV6_ADDR_UNREACH, 0, skb->dev);
>  discard:

I'd argue this.  We probably should not send back any ICMPv6 packets 
to the original sender in this case to avoid DoS.

--yoshfuji.
