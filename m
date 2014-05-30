From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: Re: [PATCH 1/1] driver: net: smsc911x: set NOCARRIER flag in driver initialization
Date: Fri, 30 May 2014 18:35:43 +0530
Message-ID: <CAHPKR9KmDSgC9EstJLfhqY9SB462OSJhQCEPS7Ka=VvnqbH6iQ@mail.gmail.com>
References: <5380EAF6.1090402@gmail.com>
	<20140529.152809.871745461296745132.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:57755 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbaE3NFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 09:05:49 -0400
Received: by mail-wi0-f177.google.com with SMTP id f8so1044660wiw.16
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 06:05:44 -0700 (PDT)
In-Reply-To: <20140529.152809.871745461296745132.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Fri, May 30, 2014 at 3:58 AM, David Miller <davem@davemloft.net> wrote:
> From: Balakumaran Kannan <kumaran.4353@gmail.com>
> Date: Sun, 25 May 2014 00:24:46 +0530
>
>> @@ -2525,6 +2525,8 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
>>
>>       netdev_info(dev, "MAC Address: %pM\n", dev->dev_addr);
>>
>> +     netif_carrier_off(dev);
>> +
>>       return 0;
>>
>
> You should do this before the network device is registered.
IMHO calling netif_carrier_off after registering device will not
affect functionality. Because,

    * Device starts carrier detection once driver's open function
calls phy_start.
    * Kernel starts network layer initialization only after __dev_open
function sets IFF_UP bit of dev->flags.
    And __dev_open sets this bit only after driver's open function returns.
    * So we could place netif_carrier_off call anywhere before
phy_start in driver's open function gets called.

Also I have referred some other drivers.

    * Intel i40e driver calls netif_carrier_off at the beginning of
driver's open (i40e_open) function.
    * e1000 driver places netif_carrier_off at the end of driver probe
(e1000_probe) function.
    * realtek r8169 driver calls netif_carrier_off at the end of
driver init (rtl_init_one) function.

All these drivers call netif_carrier_off function after registering
the network device using register_netdev.

This explanation is based on my understanding. Please explain to me if
I'm wrong or I miss something. In such case I'll modify the patch
accordingly.

Thank you.

Regards,
K.Balakumaran
