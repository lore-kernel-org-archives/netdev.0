From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.18 2/3] tg3: Convert to non-LLTX
Date: Mon, 05 Jun 2006 16:06:17 -0700 (PDT)
Message-ID: <20060605.160617.28789835.davem@davemloft.net>
References: <1149536852.13155.7.camel@rh4>
	<20060605155834.031d37a2@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, herbert@gondor.apana.org.au, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29404
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750768AbWFEXGP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 19:06:15 -0400
To: shemminger@osdl.org
In-Reply-To: <20060605155834.031d37a2@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 5 Jun 2006 15:58:34 -0700

> Perhaps there is something simpler that could be done with a ring
> model and some atomic primitives like cmpxchg()?

cmpxchg() is something not available natively on many platforms, you
can't even emulate it %100 properly on systems that just have some
kind of test-and-set spinlock type primitive.

You can synchronize the cmpxchg() itself using a spinlock on such
platforms, but you cannot synchronize the accesses done by other
processors which do not use cmpxchg().

So using cmpxchg() would block out such platforms from being able
to use the tg3 driver any longer, which really isn't an option.
