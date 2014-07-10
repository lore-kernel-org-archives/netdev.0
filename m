From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net v2 3/7] net: cpmac: dynamic debug fixes
Date: Thu, 10 Jul 2014 14:15:43 +0530
Message-ID: <53BE52B7.40107@gmail.com>
References: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>	 <1404970545-26508-4-git-send-email-varkabhadram@gmail.com> <1404981109.8839.6.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	linux@rainbow-software.org, balbi@ti.com, george.cherian@ti.com,
	davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:54754 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbaGJIq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 04:46:56 -0400
Received: by mail-pd0-f174.google.com with SMTP id y10so10368521pdj.5
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 01:46:56 -0700 (PDT)
In-Reply-To: <1404981109.8839.6.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series already applied to net-next by David Miller.


Anyway we will discuss this. If change required i will send the patch

On 07/10/2014 02:01 PM, Joe Perches wrote:
> On Thu, 2014-07-10 at 11:05 +0530, varkabhadram@gmail.com wrote:
>> From: Varka Bhadram <varkab@cdac.in>
>>
>> This patch does the following changes
>> 1. convert printk(KERN_DEBUG.. to netdev_dbg() if we have net_device object
>>     or convert to dev_dbg() if we have device object.
> []
>> diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
> []
>> @@ -228,21 +228,20 @@ static void cpmac_dump_regs(struct net_device *dev)
>>   		if (i % 16 == 0) {
>>   			if (i)
>>   				pr_cont("\n");
>> -			printk(KERN_DEBUG "%s: reg[%p]:", dev->name,
>> -			       priv->regs + i);
>> +			netdev_dbg(dev, "reg[%p]:", priv->regs + i);
>>   		}
>> -		printk(" %08x", cpmac_read(priv->regs, i));
>> +		pr_debug(" %08x", cpmac_read(priv->regs, i));

You mean to say that the pr_debug will insert the new line ?... I dont think so..


I think this patch will do the job as you show like

<7>dev->name: reg[addr]: p1 p2 p3 p4 p5 p6 p7 p8
<7>dev->name: reg[addr]: p9 pa ...            pn
  

>>   	}
>> -	printk("\n");
>> +	pr_debug("\n");
>>   }
> This changes output from a compact form to
> usig very many individual lines like:
>
> <7>dev->name: reg[addr]: p1 p2 p3 p4 p5 p6 p7 p8
> <7>dev->name: reg[addr]: p9 pa ...            pn
>
> to:
>
> <7>bus desc/dev->name: reg[addr]:
> <7> p1
> <7> p2
> ...
> <7>bus desc/dev->name: reg[addr]:
> <7> p9
> <7> pa
> ...
> <7> pn
>
>

-- 
Regards,
Varka Bhadram.
