From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: remove special ioctl from hso driver, replace by rfkill
Date: Fri, 18 Apr 2008 01:28:56 +0200
Message-ID: <2EA56503-8726-4AF5-A383-147C3A3EC56E@holtmann.org>
References: <200804161428.18066.oliver@neukum.org> <4807C42F.9050409@teltonika.lt> <20080417223929.GA31384@kroah.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:58492 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754859AbYDQX3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 19:29:02 -0400
In-Reply-To: <20080417223929.GA31384@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

>>> /* called once for each interface upon device insertion */
>>> static int hso_probe(struct usb_interface *interface,
>>> 		     const struct usb_device_id *id)
>>> {
>>> 	int mux, i, if_num, port_spec;
>>> 	unsigned char port_mask;
>>> +	char *rfkn;
>>> 	struct hso_device *hso_dev = NULL;
>>> 	struct hso_shared_int *shared_int = NULL;
>>> 	struct hso_device *tmp_dev = NULL;
>>> @@ -2747,6 +2706,27 @@ static int hso_probe(struct usb_interfac
>>> 		goto exit;
>>> 	}
>>> +	hso_dev->rfkill =  
>>> rfkill_allocate(&interface_to_usbdev(interface)->dev,
>>> +				RFKILL_TYPE_WLAN);
>>
>> What will happen if rfkill is not enabled on kernel? I think HSO  
>> should
>> not depend on rfkill. Solution should be to do #ifdef  
>> CONFIG_RFKILL..?
>
> Ick, rfkill should degrade properly so that #ifdefs are not needed  
> here.
> I'll fix up rfkill.h to prevent this kind of dependancy requirement.

while you are at it, can you make sure we have a RFKILL_TYPE_WWAN for  
these cards and then use it. Using RFKILL_TYPE_WLAN for UMTS/GSM  
modems is wrong.

Regards

Marcel

