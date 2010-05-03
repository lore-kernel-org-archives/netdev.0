From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Avoid race in sky2_change_mtu
Date: Mon, 03 May 2010 16:36:12 -0700 (PDT)
Message-ID: <20100503.163612.37225591.davem@davemloft.net>
References: <4BDEDB50.7000707@ring3k.org>
	<20100503162634.1f004023@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mikem@ring3k.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37022
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755188Ab0ECXgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 19:36:07 -0400
In-Reply-To: <20100503162634.1f004023@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 3 May 2010 16:26:34 -0700

> On Mon, 03 May 2010 23:18:56 +0900
> Mike McCormack <mikem@ring3k.org> wrote:
> 
>> netif_stop_queue does not ensure all in-progress transmits are complete,
>>  so use netif_tx_disable() instead.
>> 
>> Make sure NAPI polls are disabled, otherwise NAPI might trigger a TX
>>  restart between when we stop the queue and NAPI is disabled.
> 
> How could NAPI trigger a TX restart? Restart is a timer, not controlled
> by NAPI. There is a different race that your patch isn't covering.

I think he meant to say that NAPI can trigger a TX queue wake, which
indeed it can, and it will if there is space in the TX queue and
we happen to see the TXIDLE status at this time.
