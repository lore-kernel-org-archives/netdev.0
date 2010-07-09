From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ks8842: Do the TX timeout work in workqueue context.
Date: Thu, 08 Jul 2010 21:43:53 -0700 (PDT)
Message-ID: <20100708.214353.59675307.davem@davemloft.net>
References: <1278429625.32432.10.camel@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: richard.rojfors@pelagicore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57794
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751337Ab0GIEnj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jul 2010 00:43:39 -0400
In-Reply-To: <1278429625.32432.10.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Richard R=F6jfors <richard.rojfors@pelagicore.com>
Date: Tue, 06 Jul 2010 17:20:25 +0200

> Currently all code that needs to be run at TX timeout is done in the
> calling context, where bottom halves are disabled. Some of the code
> blocks, so it needs to be done in a different context. This patch
> adds in a work struct which is scheduled at TX timeout. Then the
> timeout code is executed within work queue context.
>=20
> Signed-off-by: Richard R=F6jfors <richard.rojfors@pelagicore.com>

Your patch is corrupted by your email client, and it does more than
you say it does in this commit message:

>  static inline void ks8842_select_bank(struct ks8842_adapter *adapter=
,
> u16 bank)
> @@ -197,7 +199,6 @@ static void ks8842_reset(struct ks8842_adapter
> *adapter)

Your email client is wrapping long lines in the patch, corrupting it
and making it unusable.  Please fix your email client to not molest
the patch in any way.

>  	msleep(10);
>  	iowrite16(0, adapter->hw_addr + REG_GRR);
>  	*/
> -	iowrite16(32, adapter->hw_addr + REG_SELECT_BANK);
>  	iowrite32(0x1, adapter->hw_addr + REG_TIMB_RST);
>  	msleep(20);
>  }

Your commit message fails to describe what this REG_SELECT_BANK write
removal is needed for.  It must be accounted for in your log message
otherwise other developers won't understand why this line gets
removed in your change.

Thanks.
