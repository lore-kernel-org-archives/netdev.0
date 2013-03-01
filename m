From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH 1/1 net-next] fec: net: put tx to napi poll function to
 fix dead lock
Date: Fri, 1 Mar 2013 11:05:57 +0800
Message-ID: <CAHrpEqQk7ZeKicAZMN=d6wksEPzWO0dCvqj6n6Gj+2GLFJuRaA@mail.gmail.com>
References: <1362023060-10277-1-git-send-email-Frank.Li@freescale.com>
	<20130228.153942.1205752844713252540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Frank.Li@freescale.com, shawn.guo@linaro.org, B38611@freescale.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	s.hauer@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:59690 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866Ab3CADF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 22:05:59 -0500
Received: by mail-wi0-f176.google.com with SMTP id hm14so8552609wib.3
        for <netdev@vger.kernel.org>; Thu, 28 Feb 2013 19:05:57 -0800 (PST)
In-Reply-To: <20130228.153942.1205752844713252540.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/3/1 David Miller <davem@davemloft.net>:
> From: Frank Li <Frank.Li@freescale.com>
> Date: Thu, 28 Feb 2013 11:44:20 +0800
>
>> +     int tx_pkts = fec_enet_tx(ndev);
>> +
>> +     if (tx_pkts)
>> +             return budget;
>
> This isn't right, you don't want to finish the NAPI poll because
> TX work was done.
>
> Ignore the TX work for poll completion purposes, see
> drivers/net/ethernet/broadcom/tg3.c:tg3_poll_work() for
> example.

I read tg3.c code. If I understand correct,
just need remove below line

    if (tx_pkts)
             return budget;

Is it ture?
