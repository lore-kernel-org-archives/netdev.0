From: Denis Joseph Barrow <D.Barow@option.com>
Subject: Re: hso: remove usb_driver_claim_interface()
Date: Wed, 10 Sep 2008 13:34:17 +0200
Message-ID: <48C7B0B9.7020608@option.com>
References: <48C78E15.9030603@teltonika.lt> <48C7A4F5.2070607@option.com> <48C7AEDC.8060902@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.option.com ([81.246.70.162]:5281 "EHLO
	mailer1.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067AbYIJLeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 07:34:21 -0400
In-Reply-To: <48C7AEDC.8060902@teltonika.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paulius Zaleckas wrote:
Have you a hso device to test this on.
If you have & it works it gets my blessing.

> Denis Joseph Barrow wrote:
>> Hi Paulius,
>> I'm not in a position yet to know if this patch is good, yet at least.
>> hso_probe gets called once for each serial ttyHSx device
>> usually four per usb stick modem & once for the hsox network device
>> per modem.
>>  
>> From the comment on usb_driver_claim_interface
>>  * This is used by usb device drivers that need to claim more than one
>>  * interface on a device when probing (audio and acm are current
>> examples).
>>
>> I'm not used to USB terminology
>> From my understanding of the code
>> we are claiming more than one interface on the usb modem multiple
>> ttyHSx devices
>> & one network device. However we get probed once for each interface
> 
> usb_driver_claim_interface() is needed only when you want to claim
> additional interface.
> 
>> We are also calling usb_driver_release_interface from hso_disconnect.
>> This looks a little asymmetrical to me.
> 
> Nice catch. usb_driver_release_interface() is not needed there too.
> This is some code from usb_driver_release_interface():
> 
>         /* don't release from within disconnect() */
>         if (iface->condition != USB_INTERFACE_BOUND)
>                 return;
> 
> So since hso_disconnect is usb disconnect(), function call to
> usb_driver_release_interface() just returns without any action.
> I will prepare patch for this one too.
> 
> Greg: Maybe we should put warning in this check to catch other
> driver from misusing this function?
> 
>> Greg is this patch good? I've no problem with it if it gets your guys
>> blessing.
>>
>>
>> Index: linux-2.6/drivers/net/usb/hso.c
>> ===================================================================
>> --- linux-2.6.orig/drivers/net/usb/hso.c
>> +++ linux-2.6/drivers/net/usb/hso.c
>> @@ -2487,8 +2487,6 @@ static int hso_probe(struct usb_interfac
>>          goto exit;
>>      }
>>  
>> -    usb_driver_claim_interface(&hso_driver, interface, hso_dev);
>> -
>>      /* save our data pointer in this device */
>>      usb_set_intfdata(interface, hso_dev);
>>  
>>
>>
>>
>> Paulius Zaleckas wrote:
>>


-- 
best regards,
D.J. Barrow
