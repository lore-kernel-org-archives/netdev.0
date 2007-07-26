From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Wed, 25 Jul 2007 23:38:08 -0700 (PDT)
Message-ID: <20070725.233808.41635535.davem@davemloft.net>
References: <20070725.210943.122860438.davem@davemloft.net>
	<1551EAE59135BE47B544934E30FC4FC002AAB9F6@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca, rusty@rustcorp.com.au
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38407
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752047AbXGZGiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 02:38:09 -0400
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC002AAB9F6@nt-irva-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 25 Jul 2007 23:33:03 -0700

> This will lead to more and longer lock contentions between
> ->hard_start_xmit() and ->poll() in the normal fast path.  Why
> do we need to widen the scope of netif_tx_lock() in this case?

So that ->poll_controller() can process TX acks by just having
the TX lock and interrupts disabled.

Can you think of another way to process TX acks from absolutely
any execution context whatsoever?  That's what we need and
preferably in some generic way, and the above is what I came
up with.

To be honest I don't think the TX lock contention will matter, and
even if there were a small cost, the simplicity of the netpoll
implementation is worth it given how problematic and hard to debug
netpoll has been in the past.
