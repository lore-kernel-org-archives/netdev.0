From: David Miller <davem@davemloft.net>
Subject: Re: [Bug #14925] sky2 panic under load
Date: Tue, 12 Jan 2010 00:08:04 -0800 (PST)
Message-ID: <20100112.000804.186755338.davem@davemloft.net>
References: <20100111220753.GC3139@del.dom.local>
	<20100111.161419.138918787.davem@davemloft.net>
	<20100112075059.GA6628@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, mikem@ring3k.org, flyboy@gmail.com,
	rjw@sisk.pl, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58173
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752542Ab0ALIH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 03:07:56 -0500
In-Reply-To: <20100112075059.GA6628@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 12 Jan 2010 07:50:59 +0000

> I think, I can see similar problems e.g. in gianfar or netxen, where
> napi_disable() is done after netif_device_detach(), especially in
> suspend procedures (there might be less severe (than oops) effects
> yet). IMHO, it all looks simply error prone (sometime you have to
> know a driver well to track all possible paths to say it's really
> safe).

Then that's an even larger bug.

Until you do napi_disable(), the device can be touched.

Asynchronous paths outside of the driver's control, even
with interrupts disabled, can call back into the driver
and touch the chip.

F.e. netpoll via netconsole output on another cpu

So it therefore must be done before doing the actual work of bringing
the device down or suspending it.
