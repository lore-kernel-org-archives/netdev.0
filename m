From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCH net-next 5/7] qlcnic: fix default operating state of
 interface
Date: Sun, 19 Jun 2011 21:14:50 -0700
Message-ID: <56E7FAE7-A409-4E5C-8D1C-E8D33ACB2051@qlogic.com>
References: <1308256659-19895-1-git-send-email-anirban.chakraborty@qlogic.com>
 <1308256659-19895-5-git-send-email-anirban.chakraborty@qlogic.com>
 <20110617.001035.1602476678651330954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Amit Salecha <amit.salecha@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe001.messaging.microsoft.com ([213.199.154.139]:52238
	"EHLO DB3EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750863Ab1FTEOr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 00:14:47 -0400
In-Reply-To: <20110617.001035.1602476678651330954.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 16, 2011, at 9:10 PM, David Miller wrote:

> From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> Date: Thu, 16 Jun 2011 13:37:36 -0700
> 
>> From: Amit Kumar Salecha <amit.salecha@qlogic.com>
>> 
>> Currently interface shows status as RUNNING, even if there is no link.
>> To fix this, netif_carrier_off should be called after register_netdev().
>> 
>> netif_carrier_off calls linkwatch_fire_event(dev); only if netdev is registered,
>> otherwise it skips. linkwatch_fire_event set default state of nic interface.
>> 
>> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
>> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> 
> You cannot do this.
> 
> The exact second that register_netdev() is called, the device can
> be brought up asynchronously and the link brought into the up state.
> 
> Your netif_carrier_off() call will race with this.
> 
> This is why no other (properly functioning) driver does what you're
> trying to do here.
> 

We will take care of it. Please ignore the series. 

thanks much,
Anirban



