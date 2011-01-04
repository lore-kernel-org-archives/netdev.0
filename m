From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] can: add driver for Softing card
Date: Tue, 04 Jan 2011 09:31:00 -0800 (PST)
Message-ID: <20110104.093100.71129805.davem@davemloft.net>
References: <20110103163835.GD320@e-circ.dyndns.org>
	<20110103.093327.104057155.davem@davemloft.net>
	<4D22FC72.7040706@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kurt.van.dijck@eia.be, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47053
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751941Ab1ADRa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 12:30:29 -0500
In-Reply-To: <4D22FC72.7040706@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Tue, 04 Jan 2011 11:54:42 +0100

> There's ioread() and get_unaligned(). Do we have a combination of this?

No.  And there will never be.

Because it's never well defined whether it is safe to break up an
I/O operation into two sub-operations, nor in what order those
sub-operations can be done in.

For example, just reading one byte of a two-byte register might
clear the status bits in other byte if the two bytes are read in
the wrong order.

On some chips, avoiding losing information might be completely
impossible.

You have to do it by hand in your driver, because only you know
what implementation will work correctly.
