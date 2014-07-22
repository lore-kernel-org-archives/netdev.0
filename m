From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] ethernet: realtek: use module_pci_driver
Date: Tue, 22 Jul 2014 13:54:17 +0530
Message-ID: <53CE1FB1.6020809@gmail.com>
References: <1406013622-27869-1-git-send-email-varkabhadram@gmail.com>	<1406013622-27869-2-git-send-email-varkabhadram@gmail.com> <20140722.002850.1113335731441581168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, varkabhadram@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:58816 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619AbaGVIZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 04:25:36 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so10810858pdj.28
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 01:25:35 -0700 (PDT)
In-Reply-To: <20140722.002850.1113335731441581168.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2014 12:58 PM, David Miller wrote:
> From: varkabhadram@gmail.com
> Date: Tue, 22 Jul 2014 12:50:21 +0530
>
>> @@ -1887,11 +1887,7 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
>>   	resource_size_t pciaddr;
>>   	unsigned int addr_len, i, pci_using_dac;
>>   
>> -#ifndef MODULE
>> -	static int version_printed;
>> -	if (version_printed++ == 0)
>> -		pr_info("%s", version);
>> -#endif
>> +	pr_info("%s", version);
> Now you're changing behavior undesirably, it will now print the
> version string into the logs for every instance of the device which is
> discovered.
>
> Seriously, the driver is worse off after these "cleanups".

Here we are having two possibilities here:

1. Removing the version info completely. Ofcourse this is not desirable.
  
2. Accepting the version info to be print into log messages.

I will put like this by removing #ifdefs:
	static int version_printed;
	if (version_printed++ == 0)
		pr_info("%s", version);


Will it be OK ..?

-- 
Regards,
Varka Bhadram.
