From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH] mv643xx_eth: Fix a possible deadlock upon ifdown
Date: Fri, 01 Mar 2013 18:30:13 +0100
Message-ID: <5130E5A5.90303@ahsoftware.de>
References: <1357308422-19639-1-git-send-email-lkundrak@v3.sk> <20130104202509.GX27530@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lubomir Rintel <lkundrak@v3.sk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Lubomir Rintel <lubo.rintel@gooddata.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1446028.stratoserver.net ([85.214.92.142]:46394 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151Ab3CARmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 12:42:35 -0500
In-Reply-To: <20130104202509.GX27530@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 04.01.2013 21:25, schrieb Lennert Buytenhek:
> On Fri, Jan 04, 2013 at 03:07:02PM +0100, Lubomir Rintel wrote:
>
>> From: Lubomir Rintel <lubo.rintel@gooddata.com>
>>
>> =================================
>> [ INFO: inconsistent lock state ]
>> 3.7.0-6.luboskovo.fc19.armv5tel.kirkwood #1 Tainted: G        W
>> ---------------------------------
>> inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
>> NetworkManager/337 [HC0[0]:SC0[0]:HE1:SE1] takes:
>>   (_xmit_ETHER#2){+.?...}, at: [<bf07adfc>] txq_reclaim+0x54/0x264 [mv643xx_eth]

I get the same annoying warning when the MTU gets changed (through dhcp).

>
> Maybe I'm not reading it right, but I doubt that this is an actual
> deadlock or that the patch is needed.
>
> txq_reclaim() indeed doesn't disable BHs, but that's because it's
> always called in BH context.  Almost always -- the only exception is
> txq_deinit(), called from ->ndo_stop(), but by that time we've
> already napi_disable()'d and netif_carrier_off()'d and free_irq()'d.

Agreed. I've just read me through that too and don't think a deadlock is 
possible.

>
> How to explain that to lockdep, though, I don't know.

The patch helps with that. ;)

Regards,

Alexander
