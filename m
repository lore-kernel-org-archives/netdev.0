From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] enc28j60: reduce the number of spi transfers in
 enc28j60_set_bank()
Date: Thu, 18 Dec 2008 19:39:24 -0800 (PST)
Message-ID: <20081218.193924.157025825.davem@davemloft.net>
References: <20081218075732.GA1880@diamond.tkos.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lanconelli.claudio@eptar.com, netdev@vger.kernel.org
To: baruch@tkos.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47805
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752237AbYLSDjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 22:39:22 -0500
In-Reply-To: <20081218075732.GA1880@diamond.tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baruch Siach <baruch@tkos.co.il>
Date: Thu, 18 Dec 2008 09:57:32 +0200

> A major source of overhead in the enc28j60 driver is the SPI transfers. Each 
> SPI transfer entails two kernel thread context switches. One major source of 
> SPI transfers is the enc28j60_set_bank() functions which runs before every 
> register access. This patch reduces the number of SPI transfers that 
> enc28j60_set_bank() performs in two ways:
> 
>   1. removes unnecessary bank switch for the registers that are present in all 
> 	 banks
> 
>   2. when switching from banks 0 or 3 to banks 1 or 2 (i.e. only one bit 
> 	 changes) enc28j60_set_bank() does only one SPI transfer instead of two
> 
> According to my tests these changes reduce the number of SPI transfers in 
> about 25%.
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>

Applied, thanks Baruch.
