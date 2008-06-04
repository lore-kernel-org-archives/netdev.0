From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 1/2][L2TP]: Fix possible WARN_ON from socket code when
 UDP socket is closed
Date: Wed, 04 Jun 2008 23:33:06 +0100
Message-ID: <48471822.3050202@katalix.com>
References: <200806042056.m54KuiI7003060@quickie.katalix.com>	<20080604.150835.73786340.davem@davemloft.net> <20080604.151146.104754883.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:53621 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758423AbYFDWdL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 18:33:11 -0400
In-Reply-To: <20080604.151146.104754883.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 04 Jun 2008 15:08:35 -0700 (PDT)
> 
>> Applied, thanks.
> 
> James your second patch doesn't apply cleanly:
> 
> @@ -1066,7 +1100,7 @@ static int pppol2tp_xmit(struct ppp_chan
>  	dst_release(skb->dst);
>  	skb->dst = dst_clone(__sk_dst_get(sk_tun));
>  	skb_orphan(skb);
> -	skb->sk = sk_tun;
> +	pppol2tp_skb_set_owner_w(skb, sk_tun);
>  
>  	/* Queue the packet to IP for output */
>  	len = skb->len;
> 
> There is no skb_orphan() call in the current pppol2tp.c code.
> 
> Please always prepare your patches against the current tree.

My apologies. I sent the wrong patch version. The skb_orphan() call was 
moved in the truesize patch that has already been applied. Shall I resend?

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

