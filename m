From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ks8842: Do the TX timeout work in workqueue context.
Date: Thu, 08 Jul 2010 23:07:20 -0700 (PDT)
Message-ID: <20100708.230720.260093060.davem@davemloft.net>
References: <1278655286.5481.4.camel@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: richard.rojfors@pelagicore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57830
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751375Ab0GIGHG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jul 2010 02:07:06 -0400
In-Reply-To: <1278655286.5481.4.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Richard R=F6jfors <richard.rojfors@pelagicore.com>
Date: Fri, 09 Jul 2010 08:01:26 +0200

> Currently all code that needs to be run at TX timeout is done in the
> calling context, where bottom halves are disabled. Some of the code
> blocks, so it needs to be done in a different context. This patch
> adds in a work struct which is scheduled at TX timeout. Then the
> timeout code is executed within work queue context.
>=20
> In the process an unnecessary bank change before resetting the
> controller was removed.
>=20
> Signed-off-by: Richard R=F6jfors <richard.rojfors@pelagicore.com>

If the bank change removal is unrelated to this change you should
do it in a seperate change.

This way it's easy for someone to find out if a regression is
caused by the TX workqueue bits, rather than this bank change
removal.

So, please submit this as a two patch sequence, one that does
the bank change line removal.  And then a second that does
the TX workqueue bits.

Thanks.
