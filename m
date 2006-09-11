From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] VIOC: New Network Device Driver
Date: Mon, 11 Sep 2006 21:15:52 +0200
Message-ID: <200609112115.53520.arnd@arndb.de>
References: <003c01c6d5cb$e00fd850$7501a8c0@ZINLAPTOP>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:17149 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S964969AbWIKTQA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 15:16:00 -0400
To: "Misha Tomushev" <misha@fabric7.com>
In-Reply-To: <003c01c6d5cb$e00fd850$7501a8c0@ZINLAPTOP>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 11 September 2006 19:58, Misha Tomushev wrote:
> The descriptor clean-up does not contribute anything to the performance
> of the driver, it just replenishes the memory pools. It almost does not
> need interrupts. Why would we want to add more cycles to the receive
> logic, when driver is doing useful work for something that can run
> almost at any time?

It can run at almost any time, just not in the interrupt context,
where it needs to schedule the tx softirq first.

Also, the number of tx interrupts you get is a tradeoff between
causing overhead of calling the interrupt handler and stalling
sockets that are waiting for space to become free after transmission.
By using ->poll for it, you can avoid tx interrupts completely
most of the time and free skbs immediately when data comes in.

	Arnd <><
