From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: de4x5: Omit check for multicast bit in
 netdev_for_each_mc_addr
Date: Thu, 30 Jun 2011 23:57:30 -0700 (PDT)
Message-ID: <20110630.235730.726339338074212677.davem@davemloft.net>
References: <1309349760-1776-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36269 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755002Ab1GAG5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 02:57:40 -0400
In-Reply-To: <1309349760-1776-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Wed, 29 Jun 2011 14:16:00 +0200

> There is no need to check for the address being a multicast address in
> the netdev_for_each_mc_addr loop, so remove it.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Please build test your patches!

> @@ -1954,7 +1954,6 @@ SetMulticastFilter(struct net_device *dev)
>      u16 hashcode;
>      u32 omr, crc;
>      char *pa;
> -    unsigned char *addrs;
>  
>      omr = inl(DE4X5_OMR);
>      omr &= ~(OMR_PR | OMR_PM);

You removed this local variable 'addrs' but you did not remove
all uses of that variable, so the build will fail.
