From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [patch] document hci_usb as broken
Date: Sat, 19 Apr 2008 19:57:40 +0200
Message-ID: <20080419175739.GA13774@elf.ucw.cz>
References: <200804182046.m3IKksxT014631@imap1.linux-foundation.org> <55DEC459-2D49-4366-88CC-21E9CA6783DC@holtmann.org> <20080418142153.4e0eb83b.akpm@linux-foundation.org> <84989B1A-CC23-4E81-B2E2-06E5FA01612E@holtmann.org> <20080419164628.GA2214@elf.ucw.cz> <D3ACF6D0-E21F-4680-9CB1-1FE762C532AE@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	hidave.darkstar@gmail.com, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.31.123]:53541 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755436AbYDSR45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2008 13:56:57 -0400
Content-Disposition: inline
In-Reply-To: <D3ACF6D0-E21F-4680-9CB1-1FE762C532AE@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

>> index 075598e..20d9279 100644
>> --- a/drivers/bluetooth/Kconfig
>> +++ b/drivers/bluetooth/Kconfig
>> @@ -3,13 +3,16 @@ menu "Bluetooth device drivers"
>> 	depends on BT
>>
>> config BT_HCIUSB
>> -	tristate "HCI USB driver"
>> +	tristate "HCI USB driver (dangerous, use alternate driver below)"
>> 	depends on USB
>> 	help
>> 	  Bluetooth HCI USB driver.
>> 	  This driver is required if you want to use Bluetooth devices with
>> 	  USB interface.
>>
>> +	  Unfortunately, locking in this driver is fatally broken; it will
>> +	  corrupt memory on surprise disconnect and during resume.
>> +
>> 	  Say Y here to compile support for Bluetooth USB devices into the
>> 	  kernel or say M to compile it as module (hci_usb).
>
> this would be fine with me. Acked-by: Marcel Holtmann <marcel@holtmann.org>
>
>> diff --git a/drivers/bluetooth/hci_usb.c b/drivers/bluetooth/hci_usb.c
>> index 192522e..6cc96b4 100644
>> --- a/drivers/bluetooth/hci_usb.c
>> +++ b/drivers/bluetooth/hci_usb.c
>> @@ -1,8 +1,22 @@
>> -/*
>> +/*
>> +
>> +    This driver has fatally broken locking.
>> +
>> +    DO NOT USE.
>> +
>> +    See btusb.c for cleaner / shorter / actually working driver.
>
> NAK to this hunk. Not needed. The Kconfig help is enough.

Developers trying to debug hci_usb problems will nor see the help
text, since they probably have it enabled in their .config already and
will not be asked again...

								Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
