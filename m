From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH] net-thunder: One check less in
 nicvf_register_interrupts() after error detection
Date: Thu, 7 Jan 2016 20:30:47 +0100
Message-ID: <568EBCE7.4060502@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5685A273.6070607@users.sourceforge.net>
 <20160107110701.GE25086@rric.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil Goutham <sgoutham@cavium.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Robert Richter <rric@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:55887 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752731AbcAGTbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2016 14:31:35 -0500
In-Reply-To: <20160107110701.GE25086@rric.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Adjust a jump target to eliminate a check before error logging.
>> Use the identifier "report_failure" instead of "err".
> 
> I don't see much value in those changes.

Thanks for your feedback.


> Using the 'err' label is ok as it is not misleading and common use.

Is such a short jump label enough explanation for the information
"what" and "why"?


> And, there is no need to optimize the check since this is not the fast path

Really? - Is it a bit more efficient to avoid a double check for the
variable "ret" at the end of the current implementation for the
discussed function?
https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/tree/drivers/net/ethernet/cavium/thunder/nicvf_main.c?id=40fb5f8a60f33133d36afde35a9ad865d35e4423#n940


> and will be compiler optimized anyway.

How sure are you about automatic software optimisations?

Can it occasionally help to jump to the really intended source code
location directly?


>> @@ -944,13 +944,12 @@ static int nicvf_register_interrupts(struct nicvf *nic)
>>  	ret = request_irq(nic->msix_entries[irq].vector,
>>  			  nicvf_qs_err_intr_handler,
>>  			  0, nic->irq_name[irq], nic);
>> -	if (!ret)
>> +	if (!ret) {
>>  		nic->irq_allocated[irq] = true;
>> -
>> -err:
>> -	if (ret)
>> -		netdev_err(nic->netdev, "request_irq failed, vector %d\n", irq);
>> -
>> +		return 0;
>> +	}
>> +report_failure:
>> +	netdev_err(nic->netdev, "request_irq failed, vector %d\n", irq);
>>  	return ret;
>>  }
