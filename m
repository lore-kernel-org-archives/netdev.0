From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: Re: [net-2.6 PATCH] mlx4_en: Fix a kernel panic when waking tx queue
Date: Tue, 26 May 2009 09:49:40 +0300
Message-ID: <4A1B9104.8050405@mellanox.co.il>
References: <4A0AB34A.10100@mellanox.co.il><4A1948D7.8010504@mellanox.co.il><4A1A57AA.1080209@mellanox.co.il> <20090525.014435.203274473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tziporet Koren <tziporet@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:39047 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753204AbZEZGtU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2009 02:49:20 -0400
In-Reply-To: <20090525.014435.203274473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> Date: Mon, 25 May 2009 11:32:42 +0300
> 
>> This patch fixes a kernel panic when waking the TX queue
>> from irq context.
>>
>> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> 
> Why does it fix a panic?  What does the panic look like?
> What causes it?
> 
> Commit message is way too terse, please fix this and resubmit.
> 
Hello Dave,

I did some further investigation on this case.
The patch that I sent was only handling the symptoms instead of fixing the problem.
The panic was caused due to a race when handling TX completions and waking the queue if it was stopped.
When the transmit queue gets full, the driver enables interrupts for TX completions in order to handle
them as fast as possible.
The result was that the driver approached the transmit queue from several different contexts and this
was the bug.
I prepared a new patch fixing the race, it was running for several hours now, the bug didn't happen.

Thanks,
Yevgeny
