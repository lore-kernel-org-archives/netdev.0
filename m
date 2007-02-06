From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3 : avoid an expensive divide
Date: Tue, 06 Feb 2007 13:19:08 -0800 (PST)
Message-ID: <20070206.131908.13769204.davem@davemloft.net>
References: <200702061536.18800@nienna>
	<20070206.114659.107250775.davem@davemloft.net>
	<45C8EAC4.9020803@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56961
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965518AbXBFVTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 16:19:09 -0500
In-Reply-To: <45C8EAC4.9020803@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 06 Feb 2007 21:53:24 +0100

> I am using gcc-4.1.1, so the following comment from drivers/net/tg3.c seems 
> over-optimistic :
> 
> /* Do not place this n-ring entries value into the tp struct itself,
>   * we really want to expose these constants to GCC so that modulo et
>   * al.  operations are done with shifts and masks instead of with
>   * hw multiply/modulo instructions.  Another solution would be to
>   * replace things like '% foo' with '& (foo - 1)'.
>   */
> #define TG3_RX_RCB_RING_SIZE(tp)        \
>          ((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ?  512 : 1024)

Because I've seen gcc optimize this properly before (at least on
sparc64), it means that either:

1) There is a GCC bug where the properties of the constants
   do not propagate.

2) GCC really thinks the divide is cheaper (code density vs.
   cycle count tradeoffs etc.)

Anyways, we should probably apply your patch in any event.

Michael, any objections?
