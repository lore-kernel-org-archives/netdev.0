From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 2/6]: powerpc/cell spidernet low watermark patch.
Date: Sun, 20 Aug 2006 16:31:49 +1000
Message-ID: <1156055509.5803.77.camel@localhost.localdomain>
References: <20060818220700.GG26889@austin.ibm.com>
	 <20060818222146.GI26889@austin.ibm.com>  <200608190109.15129.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, akpm@osdl.org,
	James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	ens Osterkamp <Jens.Osterkamp@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:9352 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1750759AbWHTGcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2006 02:32:39 -0400
To: Arnd Bergmann <arnd@arndb.de>
In-Reply-To: <200608190109.15129.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> card->low_watermark->next->dmac_cmd_status |= SPIDER_NET_DESCR_TXDESFLG;
> mb();
> card->low_watermark->dmac_cmd_status &= ~SPIDER_NET_DESCR_TXDESFLG;
> card->low_watermark = card->low_watermark->next;
> 
> when we queue another frame for TX.

I would have expected those to be racy vs. the hardware... what if the
hardware is updating dmac_cmd_status just as your are trying to and the
bit out of it ?

Ben


