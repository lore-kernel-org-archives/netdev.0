From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: Re: [PATCH V2 net 02/20] net/ena: fix error handling when probe fails
Date: Mon, 5 Dec 2016 20:23:54 +0200
Message-ID: <06047e0e-c6e4-50f8-7bca-ccea0a77c9e5@annapurnalabs.com>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
 <1480857578-5065-3-git-send-email-netanel@annapurnalabs.com>
 <20161205040955.GC4310@u54ee753d2d1854bda401.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org, dwmw@amazon.com, zorik@annapurnalabs.com,
        alex@annapurnalabs.com, saeed@annapurnalabs.com, msw@amazon.com,
        aliguori@amazon.com, nafea@annapurnalabs.com
To: Matt Wilson <msw@amzn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38607 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751573AbcLESZb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 13:25:31 -0500
Received: by mail-wm0-f54.google.com with SMTP id f82so102329338wmf.1
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 10:23:58 -0800 (PST)
In-Reply-To: <20161205040955.GC4310@u54ee753d2d1854bda401.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2016 06:09 AM, Matt Wilson wrote:
> On Sun, Dec 04, 2016 at 03:19:20PM +0200, Netanel Belgazal wrote:
>> When driver fails in probe, it will release all resources, including
>> adapter.
>> In case of probe failure, ena_remove should not try to free the adapter
>> resources.
> Please word wrap your commit message around 75 columns.

OK

>
>> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
> Reviewed-by: Matt Wilson <msw@amazon.com>
>
>> ---
>>   drivers/net/ethernet/amazon/ena/ena_netdev.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
>> index 33a760e..397c9bc 100644
>> --- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
>> +++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
>> @@ -3054,6 +3054,7 @@ static int ena_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>>   err_free_region:
>>   	ena_release_bars(ena_dev, pdev);
>>   err_free_ena_dev:
>> +	pci_set_drvdata(pdev, NULL);
>>   	vfree(ena_dev);
>>   err_disable_device:
>>   	pci_disable_device(pdev);
