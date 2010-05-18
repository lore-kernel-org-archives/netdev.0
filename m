From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] Fix SJA1000 command register writes on SMP systems
Date: Tue, 18 May 2010 14:03:19 -0700 (PDT)
Message-ID: <20100518.140319.257494929.davem@davemloft.net>
References: <4BF2E512.1090109@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34626
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753196Ab0ERVDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 17:03:10 -0400
In-Reply-To: <4BF2E512.1090109@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Tue, 18 May 2010 21:05:54 +0200

> The SJA1000 command register is concurrently written in the rx-path to free
> the receive buffer _and_ in the tx-path to start the transmission.
> 
> The SJA1000 data sheet, 6.4.4 COMMAND REGISTER (CMR) states:
> "Between two commands at least one internal clock cycle is needed in
> order to proceed. The internal clock is half of the external oscillator
> frequency."
> 
> On SMP systems the current implementation leads to a write stall in the
> tx-path, which can be solved by adding some general locking and some time
> to settle the write_reg() operation for the command register.
> 
> Thanks to Klaus Hitschler for the original fix and detailed problem
> description.
> 
> This patch applies on net-2.6 and (with some offsets) on net-next-2.6 .
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> Acked-by: Wolfgang Grandegger <wg@grandegger.com>

Applied, thanks.
