From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: Re: Re: [PATCH kernel 3.0-rc1] smc91c92_cs: set smc->base to NULL before iounmap
Date: Tue, 7 Jun 2011 21:01:19 +0900 (JST)
Message-ID: <4999307.178051307448079250.ken_kawasaki@spring.nifty.jp>
References: <20110605.143834.1866501392102519766.davem@davemloft.net>
 <20110131061616.05b2fa6f.ken_kawasaki@spring.nifty.jp>
	<20110221000720.e93225c1.ken_kawasaki@spring.nifty.jp>
	<20110605082016.5a26f61a.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sv1.nifty.com ([220.209.183.60]:57836 "EHLO
	defg303.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752744Ab1FGMTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 08:19:03 -0400
Received: from nfmsa303g.nifmail.jp (nfmsa303 [172.22.241.47])by defg303.nifty.com with ESMTP id p57C1vAd008241
	for <netdev@vger.kernel.org>; Tue, 7 Jun 2011 21:01:57 +0900
In-Reply-To: <20110605.143834.1866501392102519766.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I will re-test this problem.

Thanks,
Ken

>> smc91c92_cs:
>>     set smc->base to NULL before iounmap
>>     to avoid writing to smc->base in smc_interrupt.
>> 
>> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
>
>The device should be completely made quiet and all interrupts
>synchronized before unmapping chip registers.  Using NULL checks
>is merely a workaround for the real problem, even though you take
>great pains to assign NULL before the iounmap() call.
>
>Perhaps putting the pcmcia_disable_device() call before the iounmap()
>will be sufficient to fix this bug.  Or perhaps that, plus a call to
>synchronize_irq() or similar.
>

