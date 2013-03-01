From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] fec: net: put tx to napi poll function to
 fix dead lock
Date: Thu, 28 Feb 2013 22:06:51 -0500 (EST)
Message-ID: <20130228.220651.893690287619309792.davem@davemloft.net>
References: <1362023060-10277-1-git-send-email-Frank.Li@freescale.com>
	<20130228.153942.1205752844713252540.davem@davemloft.net>
	<CAHrpEqQk7ZeKicAZMN=d6wksEPzWO0dCvqj6n6Gj+2GLFJuRaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Frank.Li@freescale.com, shawn.guo@linaro.org, B38611@freescale.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	s.hauer@pengutronix.de
To: lznuaa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894Ab3CADGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 22:06:54 -0500
In-Reply-To: <CAHrpEqQk7ZeKicAZMN=d6wksEPzWO0dCvqj6n6Gj+2GLFJuRaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <lznuaa@gmail.com>
Date: Fri, 1 Mar 2013 11:05:57 +0800

> 2013/3/1 David Miller <davem@davemloft.net>:
>> From: Frank Li <Frank.Li@freescale.com>
>> Date: Thu, 28 Feb 2013 11:44:20 +0800
>>
>>> +     int tx_pkts = fec_enet_tx(ndev);
>>> +
>>> +     if (tx_pkts)
>>> +             return budget;
>>
>> This isn't right, you don't want to finish the NAPI poll because
>> TX work was done.
>>
>> Ignore the TX work for poll completion purposes, see
>> drivers/net/ethernet/broadcom/tg3.c:tg3_poll_work() for
>> example.
> 
> I read tg3.c code. If I understand correct,
> just need remove below line
> 
>     if (tx_pkts)
>              return budget;
> 
> Is it ture?

Yes.
