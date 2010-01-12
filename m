From: David Miller <davem@davemloft.net>
Subject: Re: [Bug #14925] sky2 panic under load
Date: Mon, 11 Jan 2010 16:14:19 -0800 (PST)
Message-ID: <20100111.161419.138918787.davem@davemloft.net>
References: <4B4B2FBD.5090007@ring3k.org>
	<20100111084504.7adb5a1e@nehalam>
	<20100111220753.GC3139@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, mikem@ring3k.org, flyboy@gmail.com,
	rjw@sisk.pl, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54140
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752355Ab0ALAOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 19:14:11 -0500
In-Reply-To: <20100111220753.GC3139@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 11 Jan 2010 23:07:54 +0100

> I don't agree: you both try to make this check more specific.
> Actually, since this problem is quite tricky, I wondered about
> making it more genaral and visible for other maintainers by
> adding something like netif_wake_queue_present() with the
> check and some comment.

This detracts from the real problem.

The issue is that we have a code path bringing a device down, which
uses helper routines which are meant to be executed when the device is
up and functioning normally.

That's the bug.

No other driver does silly things like call helper routines which wake
the TX queue when taking the chip down.

Fix that, not the immediate symptoms.  Write a routine that
unconditionally clears the TX queue, frees the packets, etc. and
has none of the wake logic.

That's what most other driver do, and those that don't should be
fixed similarly.

