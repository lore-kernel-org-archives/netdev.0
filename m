From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Wed, 25 Jul 2007 23:43:42 -0700 (PDT)
Message-ID: <20070725.234342.63127611.davem@davemloft.net>
References: <20070725.210943.122860438.davem@davemloft.net>
	<1551EAE59135BE47B544934E30FC4FC002AAB9F7@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca, rusty@rustcorp.com.au
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55427
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757458AbXGZGnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 02:43:43 -0400
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC002AAB9F7@nt-irva-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 25 Jul 2007 23:39:18 -0700

> David Miller wrote:
> 
> > As a result there is no more messing around with fake NAPI polls and
> > all that other crap, instead ->poll_controller() merely has to try to
> > process TX queue acks to free up space and wake up the transmit
> > queue(s) of the device.
> > 
> 
> I think we also need to take care of link change interrupts as well.

Since netpoll is best-effort, we can elide that I think.
The more requirements you put into this ->poll_controller()
handler, the more complicated it gets.

Furthermore, this should work out.  If the link is down, the top level
poll loop will timeout waiting for the TX queue to open up, which will
kick the netpoll processing into a work queue, the link handling will
be allowed to occur meanwhile.
