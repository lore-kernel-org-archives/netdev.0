From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH]: fix lro_gen_skb() alignment
Date: Fri, 30 Nov 2007 11:14:43 -0800
Message-ID: <ada3aunlf4s.fsf@cisco.com>
References: <E1Iy2ey-0005eY-00@gondolin.me.apana.org.au>
	<475057E4.3000909@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	ossthema@de.ibm.com, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:19396 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760921AbXK3TOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 14:14:53 -0500
In-Reply-To: <475057E4.3000909@myri.com> (Andrew Gallatin's message of "Fri, 30 Nov 2007 13:35:16 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > >> -       skb = netdev_alloc_skb(lro_mgr->dev, hlen);
 > >> +       skb = netdev_alloc_skb(lro_mgr->dev, hlen + NET_IP_ALIGN);
 > > NET_IP_ALIGN should only be used if you're DMAing into the skb head.
 > > Otherwise you should say 2.  It would be nice to have another macro
 > > for that I suppose.
 > 
 > It is certainly simple enough to say 2.  Thank you for pointing
 > this out.  I have attached a patch to do that..
 > 
 > Signed off by: Andrew Gallatin <gallatin@myri.com>

Isn't the value of 2 ethernet-specific (to round the 14-byte header up
to 16)?  Given that the rest of the lro code is fairly careful to
calculate mac_hdr_len etc it seems as if it would be cleaner to make
this independent of the specific L2 being used.

(And I plan on using the LRO module for IP-over-InfiniBand so this is
not completely theoretical)

 - R.
