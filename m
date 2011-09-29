From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net/stable] can bcm: fix tx_setup off-by-one errors
Date: Thu, 29 Sep 2011 09:46:46 +0200
Message-ID: <4E842266.9090407@hartkopp.net>
References: <4E7CCEB3.4050408@hartkopp.net> <20110929.003317.223715542181691202.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, nautsch@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:50246 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904Ab1I2Huk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 03:50:40 -0400
In-Reply-To: <20110929.003317.223715542181691202.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/11 06:33, David Miller wrote:

> From: Oliver Hartkopp <socketcan@hartkopp.net>
> Date: Fri, 23 Sep 2011 20:23:47 +0200
> 
>> This patch fixes two off-by-one errors that canceled each other out.
>> Checking for the same condition two times in bcm_tx_timeout_tsklet() reduced
>> the count of frames to be sent by one. This did not show up the first time
>> tx_setup is invoked as an additional frame is sent due to TX_ANNONCE.
>> Invoking a second tx_setup on the same item led to a reduced (by 1) number of
>> sent frames.
>>
>> Reported-by: Andre Naujoks <nautsch@gmail.com>
>> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> 
> Applied, and queued up for -stable.


Hello Dave,

when backporting the patch to an older kernel we discovered a problem this
patch is introducing - which causes a new regression :-(

Could you please revert this patch and dequeue it from stable?

We'll send a new patch for net-next as this fix changes/repairs the behaviour
of the count variable. Therefore it's probably better to have a fixed Kernel
version where the fix emerges. Or should we better not fix it at all and
document it in 'know bugs' ?

Sorry for that noise ...

Thanks,
Oliver
