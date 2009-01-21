From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] ehea: Improve driver behaviour in low mem
 conditions
Date: Wed, 21 Jan 2009 14:47:22 -0800 (PST)
Message-ID: <20090121.144722.52306013.davem@davemloft.net>
References: <200901211549.41352.tklein@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, raisch@de.ibm.com, ossthema@de.ibm.com,
	themann@de.ibm.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, hering2@de.ibm.com
To: tklein@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34796
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752736AbZAUWrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 17:47:20 -0500
In-Reply-To: <200901211549.41352.tklein@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Klein <tklein@de.ibm.com>
Date: Wed, 21 Jan 2009 15:49:41 +0100

> Reworked receive queue fill policies to make the driver more tolerant
> in low memory conditions.
> 
> Signed-off-by: Thomas Klein <tklein@de.ibm.com>

Applied, but there is an even better way to handle this.

You should be allocating replacement RX skbs at receive time.  And if
the RX allocation fails, you simply give the RX skb back to the chip
and do not pass it up into the stack.

This is what many ethernet drivers do to ensure that the chip never
can reach a situation where the free RX packet queue becomes empty.
