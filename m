From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] 3c59x: Use fine-grained locks for MII
 and windowed register access
Date: Mon, 28 Jun 2010 23:18:12 -0700 (PDT)
Message-ID: <20100628.231812.35040625.davem@davemloft.net>
References: <20100624140057.GJ5570@secunet.com>
	<1277426759.26161.179.camel@localhost>
	<20100625082447.GK5570@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org,
	chase.douglas@canonical.com, nordmark@mech.kth.se
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47962
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752045Ab0F2GSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 02:18:02 -0400
In-Reply-To: <20100625082447.GK5570@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 25 Jun 2010 10:24:47 +0200

> These locks are not needed, why you want to have them arround?

Steffen I think you are being overly picky of Ben's changes.

I'd rather have too much locking during device probe and
initialization than a subtle bug that occurs because later on someone
decides to move IRQ enabling earlier in the chip init path and now
we get strange hangs that take forever to diagnose.

I mean, extra locking in probe/init paths... ugh, there are so many
more important things to worry about!

Once Ben posts a new version of this second patch with the
proper spin_lock_init() calls added I am going to apply both
of his changes.
