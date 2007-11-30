From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH]: fix lro_gen_skb() alignment
Date: Fri, 30 Nov 2007 14:35:43 -0500
Message-ID: <4750660F.7000704@myri.com>
References: <E1Iy2ey-0005eY-00@gondolin.me.apana.org.au>	<475057E4.3000909@myri.com> <ada3aunlf4s.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	ossthema@de.ibm.com, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1924 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755035AbXK3Tgy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 14:36:54 -0500
In-Reply-To: <ada3aunlf4s.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>  > >> -       skb = netdev_alloc_skb(lro_mgr->dev, hlen);
>  > >> +       skb = netdev_alloc_skb(lro_mgr->dev, hlen + NET_IP_ALIGN);
>  > > NET_IP_ALIGN should only be used if you're DMAing into the skb head.
>  > > Otherwise you should say 2.  It would be nice to have another macro
>  > > for that I suppose.
>  > 
>  > It is certainly simple enough to say 2.  Thank you for pointing
>  > this out.  I have attached a patch to do that..
>  > 
>  > Signed off by: Andrew Gallatin <gallatin@myri.com>
> 
> Isn't the value of 2 ethernet-specific (to round the 14-byte header up
> to 16)?  Given that the rest of the lro code is fairly careful to
> calculate mac_hdr_len etc it seems as if it would be cleaner to make
> this independent of the specific L2 being used.
> 
> (And I plan on using the LRO module for IP-over-InfiniBand so this is
> not completely theoretical)

Good point.  I tend to think all the world is ethernet.
Perhaps the better way would be to simply add an alignment pad
field to lro_mgr?  When the driver initializes it, it specifies
any padding needed.  Ethernet drivers would specify 2.

Is this acceptable?

Drew
