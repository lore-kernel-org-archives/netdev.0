From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/3] qlge: Add watchdog timer.
Date: Wed, 03 Feb 2010 19:32:22 -0800 (PST)
Message-ID: <20100203.193222.64773800.davem@davemloft.net>
References: <1265217853-26959-1-git-send-email-ron.mercer@qlogic.com>
	<1265217853-26959-4-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56006
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756108Ab0BDDcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 22:32:08 -0500
In-Reply-To: <1265217853-26959-4-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Wed,  3 Feb 2010 09:24:13 -0800

> Add periodic heartbeat register read to trigger the eeh
> recovery process.
> We see cases where an eeh error was injected and the slot was
> suspended.  An asic access attempt is required to flush the recovery process,
> but without interrupts the process can stall.
> Adding this periodic register read causes the recovery process to begin.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

This does a PIO to the chip every single second?

How about something like 5 or 10 seconds, and use the
deferrable interfaces so that it's more friendly to
power management on an otherwise idle system?

Thanks.
