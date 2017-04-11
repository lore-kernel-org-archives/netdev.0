From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] net: rfkill: gpio: Add OBDA8723 ACPI HID
Date: Tue, 11 Apr 2017 16:47:46 +0200
Message-ID: <BC65C7D5-04AB-4882-8201-48FC1309A43F@holtmann.org>
References: <20170408210520.2799-1-hdegoede@redhat.com>
 <D47F8D1B-8EE0-4754-A0F2-EC823A9BDA11@holtmann.org>
 <d1206383-7fad-55ca-0717-5e485b9bee92@redhat.com>
 <0939E68A-DBF5-40BF-B83B-73AF234EB60B@holtmann.org>
 <d63b1718-910a-09e2-7a2a-f34c08c11ce6@lwfinger.net>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Hans de Goede <hdegoede@redhat.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        russianneuromancer@ya.ru,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:34498 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752900AbdDKOrv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:47:51 -0400
In-Reply-To: <d63b1718-910a-09e2-7a2a-f34c08c11ce6@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Larry,

>>>>> The OBDA8723 ACPI HID is used on quite a few Bay Trail based tablets
>>>>> for bluetooth rfkill functionality.
>>>>> 
>>>>> Tested-by: russianneuromancer@ya.ru <russianneuromancer@ya.ru>
>>>>> Signed-off-by: Hans de Goede <hdegoede@redhat.com>
>>>>> ---
>>>>> net/rfkill/rfkill-gpio.c | 1 +
>>>>> 1 file changed, 1 insertion(+)
>>>>> 
>>>>> diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
>>>>> index 76c01cb..50ca65e 100644
>>>>> --- a/net/rfkill/rfkill-gpio.c
>>>>> +++ b/net/rfkill/rfkill-gpio.c
>>>>> @@ -163,6 +163,7 @@ static int rfkill_gpio_remove(struct platform_device *pdev)
>>>>> static const struct acpi_device_id rfkill_acpi_match[] = {
>>>>> 	{ "BCM4752", RFKILL_TYPE_GPS },
>>>>> 	{ "LNV4752", RFKILL_TYPE_GPS },
>>>>> +	{ "OBDA8723", RFKILL_TYPE_BLUETOOTH },
>>>>> 	{ },
>>>>> };
>>>> 
>>>> NAK. We are integrating these with hci_bcm.c or hci_intel.c drivers.
>>> 
>>> This is for the bluetooth side of the rtl8723bs driver which recently
>>> (yesterday) got merged in into drivers/staging. Which still needs
>>> hciattach from userspace. I completely agree that eventually we should
>>> fix that. In the mean time it would be nice if we could carry this
>>> one line patch to give people using the staging driver working bluetooth.
>> 
>> why are Bluetooth drivers in staging? I objected to them before. The only reason to have them in staging would be people being to lazy to clean things up.
> 
> The Bluetooth driver is not in staging. It is only the wifi part; however, having a driver for that hardware in the kernel makes it easier for users to handle the BT part of the device. As Hans stated, the current BT driver runs in userspace. Until we actually produce hci_rtk, having this one line patch will be helpful.

I dislike RFKILL switches for Bluetooth device power control. It creates nasty userspace hacks. I have seen them and it is not a good idea. And I have seen the modified hciattach to make this devices work. That one itself is such a nasty hack. Frankly once you see struct sk_buff you should run away scared ;)

Lets get hci_rtk.c upstream. Even if it has limited support at the beginning. Also we are moving towards serdev right now and these chips will benefit greatly here.

Regards

Marcel
