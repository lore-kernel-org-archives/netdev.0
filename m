From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH 4/6] ath6kl: get rid of AR_DBG_LVL_CHECK()
Date: Thu, 5 Jan 2012 10:57:05 +0200
Message-ID: <4F0565E1.30909@qca.qualcomm.com>
References: <20120104230429.32306.75965.stgit@x201>	 <20120104230921.32306.63985.stgit@x201> <1325721515.4116.11.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linville@tuxdriver.com>, <sfr@canb.auug.org.au>,
	<netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-next@vger.kernel.org>,
	<ath6kl-devel@qualcomm.com>, <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1325721515.4116.11.camel@joe2Laptop>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/05/2012 01:58 AM, Joe Perches wrote:
> On Thu, 2012-01-05 at 01:09 +0200, Kalle Valo wrote:
>> We don't need it as debug calls already have a log level and compiler
>> should be smart enough to optimise away the code when ath6kl debug code
>> is not enabled. Also it makes it easier to abstract core code to
>> ath6kl_core.ko.
> 
> Changelog isn't representative of code changes.
> ATH6KL_DBG_ANY -> ATH6KL_DBG_IRQ.
> 
>> diff --git a/drivers/net/wireless/ath/ath6kl/debug.c b/drivers/net/wireless/ath/ath6kl/debug.c
> []
>> @@ -82,31 +82,31 @@ void ath6kl_dump_registers(struct ath6kl_device *dev,
>>  			   struct ath6kl_irq_enable_reg *irq_enable_reg)
>>  {
>>  
>> -	ath6kl_dbg(ATH6KL_DBG_ANY, ("<------- Register Table -------->\n"));
>> +	ath6kl_dbg(ATH6KL_DBG_IRQ, ("<------- Register Table -------->\n"));

It's related to this change:

-		if (AR_DBG_LVL_CHECK(ATH6KL_DBG_IRQ))
-			ath6kl_dump_registers(dev, &dev->irq_proc_reg,
-					 &dev->irq_en_reg);
+		ath6kl_dump_registers(dev, &dev->irq_proc_reg,
+				      &dev->irq_en_reg);

So instead of checking ATH6KL_DBG_IRQ before calling the function the
debug messages in function instead use ATH6KL_DBG_IRQ. I'll mention this
in the commit log.

I should get rid of that ATH6KL_DBG_ANY level completely, it's just
confusing. But I'll do that later.

Thank you for the review.

Kalle
