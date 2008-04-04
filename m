From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sc92031: sysfs link missing
Date: Fri, 04 Apr 2008 02:40:17 -0400
Message-ID: <47F5CD51.9080202@pobox.com>
References: <bug-10380-10286@http.bugzilla.kernel.org/>	<20080402091435.39f99428.akpm@linux-foundation.org>	<20080402093956.2520ebfd@extreme>	<47F5C09D.5000200@pobox.com> <20080403225216.4d2388cc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Cesar Eduardo Barros <cesarb@cesarb.net>, tom@sharkbay.at
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46178 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753228AbYDDGkU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 02:40:20 -0400
In-Reply-To: <20080403225216.4d2388cc.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Fri, 04 Apr 2008 01:46:05 -0400 Jeff Garzik <jgarzik@pobox.com> wrote:
> 
>> Stephen Hemminger wrote:
>>> Add missing sysfs device association. Compile tested only -ENOHW.
>>>
>>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>>
>>>
>>> --- a/drivers/net/sc92031.c	2008-04-02 09:34:35.000000000 -0700
>>> +++ b/drivers/net/sc92031.c	2008-04-02 09:36:53.000000000 -0700
>>> @@ -1446,6 +1446,7 @@ static int __devinit sc92031_probe(struc
>>>  	}
>>>  
>>>  	pci_set_drvdata(pdev, dev);
>>> +	SET_NETDEV_DEV(dev, &hw->pdev->dev);
>>>  
>>>  #if SC92031_USE_BAR == 0
>>>  	dev->mem_start = pci_resource_start(pdev, SC92031_USE_BAR);
>> applied
>>
> 
> That's version 1.  There was a super-optimised version 2:
> 
> 
> 
> From: Stephen Hemminger <shemminger@vyatta.com>
> 
> Add missing sysfs device association. Compile tested only -ENOHW.
> 
> Addresses http://bugzilla.kernel.org/show_bug.cgi?id=10380
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Cc: Jeff Garzik <jgarzik@pobox.com>
> Cc: Cesar Eduardo Barros <cesarb@cesarb.net>
> Cc: <tom@sharkbay.at>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/sc92031.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff -puN drivers/net/sc92031.c~sc92031-sysfs-link-missing drivers/net/sc92031.c
> --- a/drivers/net/sc92031.c~sc92031-sysfs-link-missing
> +++ a/drivers/net/sc92031.c
> @@ -1446,6 +1446,7 @@ static int __devinit sc92031_probe(struc
>  	}
>  
>  	pci_set_drvdata(pdev, dev);
> +	SET_NETDEV_DEV(dev, &pdev->dev);
>  
>  #if SC92031_USE_BAR == 0
>  	dev->mem_start = pci_resource_start(pdev, SC92031_USE_BAR);

Thanks!

After I wrote "applied", compile testing kicked it out, so I dropped it 
from the batch sent to DaveM just now.

Not even compile tested apparently..

	Jeff



