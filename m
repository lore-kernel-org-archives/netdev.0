From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] clear skb cb on IP input
Date: Sat, 15 Jul 2006 18:15:23 -0700 (PDT)
Message-ID: <20060715.181523.41634848.davem@davemloft.net>
References: <E1G1kCA-000533-00@gondolin.me.apana.org.au>
	<44B90EE2.1080808@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, guichaz@yahoo.fr,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:58006
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1946065AbWGPBPL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jul 2006 21:15:11 -0400
To: shemminger@osdl.org
In-Reply-To: <44B90EE2.1080808@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Sat, 15 Jul 2006 08:50:58 -0700

> Since skb->cb is aligned, we could optimize the initialization
> slightly by just using:
>     *(unsigned long *)skb->cb = 0;

Well, that depends upon two things.

1) How much of the ip_options really needs to be zero'd
   out initially.  From what I can tell, all 3 words really
   need it.

2) How big is an unsigned long on your computer?  It can be
   1 or 2 words, but not three :)
