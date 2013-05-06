From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH v3 1/1 net] net: fec: fix kernel oops when plug/unplug
 cable many times
Date: Mon, 6 May 2013 15:47:53 +0800
Message-ID: <CAHrpEqQybjkXOppbFvXrouqheV6NT06vd_Og5JJtmOfzY0_7Yg@mail.gmail.com>
References: <1367456138-27172-1-git-send-email-Frank.Li@freescale.com>
	<20130502.164853.1057531869767418902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Robert Schwebel <r.schwebel@pengutronix.de>,
	Lucas Stach <l.stach@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Fabio Estevam <festevam@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:44636 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753304Ab3EFHrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 03:47:55 -0400
Received: by mail-we0-f176.google.com with SMTP id r6so2801512wey.35
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 00:47:53 -0700 (PDT)
In-Reply-To: <20130502.164853.1057531869767418902.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/5/3 David Miller <davem@davemloft.net>:
> From: Frank Li <Frank.Li@freescale.com>
> Date: Thu, 2 May 2013 08:55:38 +0800
>
>> reproduce steps
>>  1. flood ping from other machine
>>       ping -f -s 41000 IP
>>  2. run below script
>>     while [ 1 ]; do ethtool -s eth0 autoneg off;
>>     sleep 3;ethtool -s eth0 autoneg on; sleep 4; done;
>>
>> You can see oops in one hour.
>>
>> The reason is fec_restart clear BD but NAPI may use it.
>> The solution is disable NAPI and stop xmit when reset BD.
>> disable NAPI may sleep, so fec_restart can't be call in
>> atomic context.
>>
>> Signed-off-by: Frank Li <Frank.Li@freescale.com>
>
> Please respin this against the current 'net' tree.

MX6 can't bootup at net and net-next tree.
I am identifying the reason.

>
> Thanks!
