From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Sat, 10 Jul 2010 19:12:42 -0700 (PDT)
Message-ID: <20100710.191242.70196353.davem@davemloft.net>
References: <8628FE4E7912BF47A96AE7DD7BAC0AADDDE646FBFB@SJEXCHCCR02.corp.ad.broadcom.com>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDE646FD52@SJEXCHCCR02.corp.ad.broadcom.com>
	<AANLkTinRUJS6e8dwqvIMhtAUWBcj5oTk-D9MMrhbL9Bk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42506
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752646Ab0GKCM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 22:12:27 -0400
In-Reply-To: <AANLkTinRUJS6e8dwqvIMhtAUWBcj5oTk-D9MMrhbL9Bk@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 7 Jul 2010 12:17:31 -0700

> It is to enable the device to provide the RSS hash in RX descriptor.
> The hash severs two purposes now, it's used internally in the device
> to perform RSS table lookup and also value in RX descriptor.  The
> latter does not require multi-queue.  Strictly speaking, on a single
> processor system without multqueue, it would be true that enabling the
> RX hash on bnx2x is currently superfluous (notwithstanding some other
> use of the hash might be implemented).

We intend to use the card provided RSS hash to optimize GSO
flow comparisons at some point.

There are other possible uses as well.

Therefore even in a single RX queue configuration, the driver
should provide the hash if it can.
