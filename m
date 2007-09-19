From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 3/3] [PPP] L2TP: Fix skb handling in pppol2tp_xmit
Date: Wed, 19 Sep 2007 09:43:49 +0100
Message-ID: <46F0E145.4020501@katalix.com>
References: <20070918120438.GA9121@gondor.apana.org.au> <E1IXbqs-0002Od-00@gondolin.me.apana.org.au> <46F032D5.7020806@katalix.com> <20070919012529.GA15046@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Paul Mackerras <paulus@samba.org>,
	=?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:38661 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754911AbXISIoF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 04:44:05 -0400
In-Reply-To: <20070919012529.GA15046@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Tue, Sep 18, 2007 at 09:19:33PM +0100, James Chapman wrote:
>> This one causes my test system to lock up. I'll investigate. Please 
>> don't apply this patch for now.
> 
> Sorry, I added a double-free on the skb after ip_queue_xmit.
> Please try this one instead.
 >
> -	/* Free the original skb */
> -	kfree_skb(skb);
> -
>  	return 1;
>  
> -discard:
> -	/* Free the new skb. Caller will free original skb. */
> -	if (skb2 != skb)
> -		kfree_skb(skb2);
>  abort:
> -	return 0;
> +	/* Free the original skb */
> +	kfree_skb(skb);
> +	return 1;
>  }

Shouldn't this return 0 in the error case and without the kfree_skb()? 
This lets ppp requeue the skb.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

