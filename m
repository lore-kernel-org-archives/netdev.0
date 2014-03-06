From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH] net: davinci_emac: Replace devm_request_irq with
 request_irq
Date: Thu, 06 Mar 2014 09:51:43 +0100
Message-ID: <A8464B1127B9570790254336@[172.22.2.41]>
References: <2ec3bb89-89db-48e8-b360-369545a2546f@mary.at.omicron.at>
 <5318318E.8030402@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jon Ringle <jon@ringle.org>
To: Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <5318318E.8030402@ti.com>
Content-Disposition: inline
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--On March 06, 2014 13:57 +0530 Mugunthan V N <mugunthanvnm@ti.com> wrote:
> On Wednesday 05 March 2014 03:55 PM, Christian Riesch wrote:
>> In commit 6892b41d9701283085b655c6086fb57a5d63fa47
>>
>> Author: Lad, Prabhakar <prabhakar.csengg@gmail.com>
>> Date:   Tue Jun 25 21:24:51 2013 +0530
>> net: davinci: emac: Convert to devm_* api
>>
>> the call of request_irq is replaced by devm_request_irq and the call
>> of free_irq is removed. But since interrupts are requested in
>> emac_dev_open, doing ifconfig up/down on the board requests the
>> interrupts again each time, causing devm_request_irq to fail.
>>
>> This patch reverts said commit partially: It changes the driver back
>> to use request_irq instead of devm_request_irq, puts free_irq back in
>> place, but keeps the remaining changes of the original patch.
>>
>> Reported-by: Jon Ringle <jon@ringle.org>
>> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
>> Cc: Lad, Prabhakar <prabhakar.csengg@gmail.com>
>> Cc: <stable@vger.kernel.org>
>
> Instead of moving back to request irq. can you move the devm interrupt
> request code from open to probe so that the issue is fixed, IRQ will be
> requested on module insert and IRQ will be free in module remove and
> there will not be any failures in devm request irq while repeating
> ifup/ifdown and also during module insert/remove.

This is exactly what I tried first, please have a look at my first patch 
and the discussion [1]. Florian Fainelli asked me to revert Prabhakar's 
patch instead to bring back the "usual situation", "just in case some 
uncontrolled interrupt bit triggers an interrupt while the interface is 
down for instance..."

Florian Fainelli, Mugunthan VN, which solution is better?

Regards, Christian

[1] http://marc.info/?t=139394310200001&r=1&w=2

>
> Regards
> Mugunthan V N
> _______________________________________________
> Davinci-linux-open-source mailing list
> Davinci-linux-open-source@linux.davincidsp.com
> http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source
