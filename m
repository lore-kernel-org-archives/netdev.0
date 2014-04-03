From: David Miller <davem@davemloft.net>
Subject: Re: ks8851: reset on RX failure and TX timeout
Date: Thu, 03 Apr 2014 13:32:03 -0400 (EDT)
Message-ID: <20140403.133203.1056561986987869608.davem@davemloft.net>
References: <b703c70840da4780bc93beed79a8503b@DB3PR02MB202.eurprd02.prod.outlook.com>
	<20140401.181355.1375673242692769955.davem@davemloft.net>
	<e095559e0b69441eb44fecc7e8639a71@DB3PR02MB202.eurprd02.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	sboyd@codeaurora.org, mjr@cs.wisc.edu, jiri@resnulli.us,
	linux-kernel@vger.kernel.org, trivial@rustcorp.com.au
To: Max.Nekludov@elster.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801AbaDCRac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 13:30:32 -0400
In-Reply-To: <e095559e0b69441eb44fecc7e8639a71@DB3PR02MB202.eurprd02.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nekludov, Max" <Max.Nekludov@elster.com>
Date: Wed, 2 Apr 2014 06:31:23 +0000

> Electromagnetic noise can make device to not send TX interrupts.
> As result outgoing queue will be suspended forever.
> Also EMI can raise RX interrupt with zero value in KS_RXFC register.
> 
> Signed-off-by: Max Nekludov <Max.Nekludov@elster.com>

We have a watchdog facility for TX timeouts, don't reinvent the wheel.

Implement ->ndo_tx_timeout() and set dev->watchdog_timeo appropriately.
