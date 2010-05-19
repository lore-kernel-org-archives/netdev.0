From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/11] netdev: bfin_mac: avoid tx skb overflows in the
 tx DMA ring
Date: Wed, 19 May 2010 13:12:19 -0700 (PDT)
Message-ID: <20100519.131219.172592870.davem@davemloft.net>
References: <AANLkTimWjjXKwi_YLFPxBrCBu1qkiuaUKyo1UW5373lH@mail.gmail.com>
	<20100518.122953.236217958.davem@davemloft.net>
	<AANLkTikKz6v09VTjtANmmcGHU1eKcVWjuDIO24KqkHWK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sonic.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53618
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752895Ab0ESUMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 16:12:10 -0400
In-Reply-To: <AANLkTikKz6v09VTjtANmmcGHU1eKcVWjuDIO24KqkHWK@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.adi@gmail.com>
Date: Wed, 19 May 2010 17:23:16 +0800

> No, this doesn't happen, because before ndo_start_xmit() returns, the
> old TX buffers and skbs in the ring, which finished DMA operation, are
> freed. The only difference is that the free operation of a skb is done
> in next tx transfer.

This is still illegal.

What if TX activity stops right then, and there is no "next tx
transfer"?

That SKB will never get freed, ever.

You have to fix this.
