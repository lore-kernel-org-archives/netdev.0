From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [patch] document hci_usb as broken
Date: Sat, 19 Apr 2008 19:40:18 +0200
Message-ID: <D3ACF6D0-E21F-4680-9CB1-1FE762C532AE@holtmann.org>
References: <200804182046.m3IKksxT014631@imap1.linux-foundation.org> <55DEC459-2D49-4366-88CC-21E9CA6783DC@holtmann.org> <20080418142153.4e0eb83b.akpm@linux-foundation.org> <84989B1A-CC23-4E81-B2E2-06E5FA01612E@holtmann.org> <20080419164628.GA2214@elf.ucw.cz>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	hidave.darkstar@gmail.com, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:40183 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753736AbYDSRkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2008 13:40:24 -0400
In-Reply-To: <20080419164628.GA2214@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pavel,

>>> ok...  But as long as the old code is buildable and installable,  
>>> we should
>>> fix bugs in it?
>>
>> I am okay with it and happy to accept any fixes, but to be quite  
>> honest,
>> that this driver still works is in some cases pure luck. Doing the  
>> URB
>> handling by ourself is really simply plain work. No excuses here  
>> and parts
>> of it is my fault. I know that. Hence I started a new  
>> implementation from
>> scratch.
>
> Ok, so I guess this is good idea... (I'd prefer previous race patch to
> still be applied; but driver is broken even with that fix...)
>
> I thought about adding && BROKEN to Kconfig...
>
> ---
>
> hci_usb is fatally broken, document it as such.
>
> Signed-off-by: Pavel Machek <pavel@suse.cz>
>
> diff --git a/drivers/bluetooth/Kconfig b/drivers/bluetooth/Kconfig
> index 075598e..20d9279 100644
> --- a/drivers/bluetooth/Kconfig
> +++ b/drivers/bluetooth/Kconfig
> @@ -3,13 +3,16 @@ menu "Bluetooth device drivers"
> 	depends on BT
>
> config BT_HCIUSB
> -	tristate "HCI USB driver"
> +	tristate "HCI USB driver (dangerous, use alternate driver below)"
> 	depends on USB
> 	help
> 	  Bluetooth HCI USB driver.
> 	  This driver is required if you want to use Bluetooth devices with
> 	  USB interface.
>
> +	  Unfortunately, locking in this driver is fatally broken; it will
> +	  corrupt memory on surprise disconnect and during resume.
> +
> 	  Say Y here to compile support for Bluetooth USB devices into the
> 	  kernel or say M to compile it as module (hci_usb).

this would be fine with me. Acked-by: Marcel Holtmann <marcel@holtmann.org 
 >

> diff --git a/drivers/bluetooth/hci_usb.c b/drivers/bluetooth/hci_usb.c
> index 192522e..6cc96b4 100644
> --- a/drivers/bluetooth/hci_usb.c
> +++ b/drivers/bluetooth/hci_usb.c
> @@ -1,8 +1,22 @@
> -/*
> +/*
> +
> +    This driver has fatally broken locking.
> +
> +    DO NOT USE.
> +
> +    See btusb.c for cleaner / shorter / actually working driver.

NAK to this hunk. Not needed. The Kconfig help is enough.

Regards

Marcel

