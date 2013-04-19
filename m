From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] URGENT for 3.9: net: fec: revert NAPI introduction
Date: Fri, 19 Apr 2013 14:26:18 -0400 (EDT)
Message-ID: <20130419.142618.500666497643088664.davem@davemloft.net>
References: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
	<CAOMZO5A_NdKJk7a7svTdB2-FzijwBoawfiM+TC8kuBmL06UsBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: l.stach@pengutronix.de, netdev@vger.kernel.org,
	Frank.Li@freescale.com, shawn.guo@linaro.org
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45278 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945Ab3DSS0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 14:26:20 -0400
In-Reply-To: <CAOMZO5A_NdKJk7a7svTdB2-FzijwBoawfiM+TC8kuBmL06UsBQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Fri, 19 Apr 2013 15:22:38 -0300

> Hi Lucas,
> 
> On Fri, Apr 19, 2013 at 11:36 AM, Lucas Stach <l.stach@pengutronix.de> wrote:
>> Those patches introduce instability to the point of kernel OOPSes with
>> NULL-ptr dereferences.
>>
>> The patches drop locks from the code without justifying why this would
>> be safe at all. In fact it isn't safe as now the controller restart can
>> happily free the RX and TX ring buffers while the NAPI poll function is
>> still accessing them. So with a heavily loaded but slightly instable
>> link we regularly end up with OOPSes because link change restarts
>> the FEC and bombs away buffers still in use.
> 
> Can you please let us know how to reproduce the oopses? Which SoC did
> you use in your tests?

You don't need to know this, he told you exactly and in detail what
the race is, so you should work on fixing that based solely upon his
explanation.
