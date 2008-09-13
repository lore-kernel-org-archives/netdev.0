From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Fix dead 21041 ethernet after ifconfig down
Date: Sat, 13 Sep 2008 15:06:51 -0400
Message-ID: <48CC0F4B.9050104@garzik.org>
References: <20080912211919.1C36FC2AFD@solo.franken.de> <20080913180509.GA8392@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	netdev@vger.kernel.org, kyle@parisc-linux.org, tbm@cyrius.com
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49561 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752467AbYIMTG6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:06:58 -0400
In-Reply-To: <20080913180509.GA8392@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Grundler wrote:
> On Fri, Sep 12, 2008 at 11:19:19PM +0200, Thomas Bogendoerfer wrote:
>> The de2104x did a pci_disable_device() in it's close function, but
>> the open function never does a pci_enable_device() and assumes that
>> the device is already enabled. Considering that downing the interface
>> is just a temporary thing the pci_disable_device() isn't a pretty good
>> idea and removing it from the close function just fixes the bug.
> 
> Thomas,
> Thanks for the patch!
> 
> The de2104 driver is calling pci_enable_device() in it's .probe routine
> and calls pci_disable_device in it's .remove function.
> It never occurred to me a NIC driver would call either pci function
> from someplace else as well.
> 
>> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
> 
> Acked-by: Grant Grundler <grundler@parisc-linux.org>
> 
>> ---
>>
>>  drivers/net/tulip/de2104x.c |    1 -
>>  1 files changed, 0 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
>> index 9281d06..f54c450 100644
>> --- a/drivers/net/tulip/de2104x.c
>> +++ b/drivers/net/tulip/de2104x.c
>> @@ -1418,7 +1418,6 @@ static int de_close (struct net_device *dev)
>>  
>>  	de_free_rings(de);
>>  	de_adapter_sleep(de);
>> -	pci_disable_device(de->pdev);

applied


