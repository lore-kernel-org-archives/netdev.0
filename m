From: "Nekludov, Max" <Max.Nekludov@elster.com>
Subject: RE: ks8851: reset on RX failure and TX timeout
Date: Thu, 10 Apr 2014 09:16:20 +0000
Message-ID: <28499d90be6a410f9a24d64b76a5c262@DB3PR02MB202.eurprd02.prod.outlook.com>
References: <b703c70840da4780bc93beed79a8503b@DB3PR02MB202.eurprd02.prod.outlook.com>
	<20140401.181355.1375673242692769955.davem@davemloft.net>
	<e095559e0b69441eb44fecc7e8639a71@DB3PR02MB202.eurprd02.prod.outlook.com>,<20140403.133203.1056561986987869608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sboyd@codeaurora.org" <sboyd@codeaurora.org>,
	"mjr@cs.wisc.edu" <mjr@cs.wisc.edu>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"trivial@rustcorp.com.au" <trivial@rustcorp.com.au>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140403.133203.1056561986987869608.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've tried to use ndo_tx_timeout. Actually it works. But it takes too long time after TX failure and before watchdog fires.

As I understand ndo_tx_timeout will be called only if tx queue is stopped. But ks8851 driver stops queue only after it's full.
So one have to  send a lot of data to reset device (~6KiB).

But I need to recover as fast as possible. Could you suggest how to achieve that?
________________________________________
From: David Miller <davem@davemloft.net>
Sent: Thursday, April 3, 2014 9:32 PM
To: Nekludov, Max
Cc: torvalds@linux-foundation.org; netdev@vger.kernel.org; sboyd@codeaurora.org; mjr@cs.wisc.edu; jiri@resnulli.us; linux-kernel@vger.kernel.org; trivial@rustcorp.com.au
Subject: Re: ks8851: reset on RX failure and TX timeout

From: "Nekludov, Max" <Max.Nekludov@elster.com>
Date: Wed, 2 Apr 2014 06:31:23 +0000

> Electromagnetic noise can make device to not send TX interrupts.
> As result outgoing queue will be suspended forever.
> Also EMI can raise RX interrupt with zero value in KS_RXFC register.
>
> Signed-off-by: Max Nekludov <Max.Nekludov@elster.com>

We have a watchdog facility for TX timeouts, don't reinvent the wheel.

Implement ->ndo_tx_timeout() and set dev->watchdog_timeo appropriately.
