From: "Bryan Wu" <cooloney@kernel.org>
Subject: Re: [PATCH 1/3] Blackfin EMAC Driver: add proper __devinit/__devexit markings
Date: Tue, 29 Jul 2008 11:34:56 +0800
Message-ID: <386072610807282034j6f6292e7u84e0e0b25fcfab6a@mail.gmail.com>
References: <1217169905-7055-1-git-send-email-cooloney@kernel.org>
	 <1217169905-7055-2-git-send-email-cooloney@kernel.org>
	 <488DE3E9.3000703@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:4228 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136AbYG2De5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 23:34:57 -0400
Received: by qw-out-2122.google.com with SMTP id 3so405442qwe.37
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2008 20:34:57 -0700 (PDT)
In-Reply-To: <488DE3E9.3000703@teltonika.lt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 28, 2008 at 11:21 PM, Paulius Zaleckas
<paulius.zaleckas@teltonika.lt> wrote:
> Bryan Wu wrote:
>>
>> From: Mike Frysinger <vapier.adi@gmail.com>
>>
>> Signed-off-by: Mike Frysinger <vapier.adi@gmail.com>
>> Signed-off-by: Bryan Wu <cooloney@kernel.org>
>> ---
>>  drivers/net/bfin_mac.c |    6 +++---
>>  1 files changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
>> index 4144343..17951cb 100644
>> --- a/drivers/net/bfin_mac.c
>> +++ b/drivers/net/bfin_mac.c
>> @@ -956,7 +956,7 @@ static int bfin_mac_close(struct net_device *dev)
>>        return 0;
>>  }
>>  -static int __init bfin_mac_probe(struct platform_device *pdev)
>> +static int __devinit bfin_mac_probe(struct platform_device *pdev)
>
> __init was OK here.
> __devinit is for hotplug devices
>
>>  {
>>        struct net_device *ndev;
>>        struct bfin_mac_local *lp;
>> @@ -1082,7 +1082,7 @@ out_err_probe_mac:
>>        return rc;
>>  }
>>  -static int bfin_mac_remove(struct platform_device *pdev)
>> +static int __devexit bfin_mac_remove(struct platform_device *pdev)
>
> __devexit is for hotplug, use __exit
>
>>  {
>>        struct net_device *ndev = platform_get_drvdata(pdev);
>>        struct bfin_mac_local *lp = netdev_priv(ndev);
>> @@ -1129,7 +1129,7 @@ static int bfin_mac_resume(struct platform_device
>> *pdev)
>>   static struct platform_driver bfin_mac_driver = {
>>        .probe = bfin_mac_probe,
>
> .probe shouldn't be declared here. And you should use
> platform_device_probe() instead of platform_device_add()
>

I failed to find platform_device_probe. Could you please provide some info?
.probe and .remove is very common in platform driver interface, isn't?
I don't know any difference between platform_device_probe() and
platform_device_add().

Thanks
-Bryan

>> -       .remove = bfin_mac_remove,
>> +       .remove = __devexit_p(bfin_mac_remove),
>
> should be __exit_p()
>
>>        .resume = bfin_mac_resume,
>>        .suspend = bfin_mac_suspend,
>>        .driver = {
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
