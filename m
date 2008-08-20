From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [PATCH] hso.c hso_net_open bugfix
Date: Wed, 20 Aug 2008 19:12:20 +0300
Message-ID: <48AC4264.7030304@teltonika.lt>
References: <48ABF311.2070405@option.com> <48AC2B32.1010505@teltonika.lt> <48AC2EA8.1050503@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list
	<public-public-linux-usb-u79uwXL29TY76Z2rM5mHXA-z5DuStaUktnZ+VzJOa5vwg@lo.gmane.org>,
	Greg Kroah-Hartman
	<public-public-gregkh-l3A5Bk7waGM-z5DuStaUktnZ+VzJOa5vwg@lo.gmane.org>,
	netdev <netdev@vger.kernel.org>
To: Denis Joseph Barrow
	<public-D.Barow-x9gZzRpC1QbQT0dZR+AlfA@lo.gmane.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:33418 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759332AbYHTQMf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Aug 2008 12:12:35 -0400
In-Reply-To: <48AC2EA8.1050503@option.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis Joseph Barrow wrote:
> 
> 
> Hi Paulus & others,
> Sorry I nearly completely agree with you the code can be left as is
> However netdev_priv check is superflous from my understanding of the code,
> admittedly if they changed the netdev_priv function the check might
> become valid.

I agree with you that odev checks in hso_net_open and hso_net_tx_timeout
are pointless and should be removed.

Please add netdev@vger.kernel.org mailing list also.

> Admittedly dev_open would crash if dev!=NULL so I agree with you it
> must be checked further up the stack.
> 
> 
> Paulius Zaleckas wrote:
>>
>> Denis Joseph Barrow wrote:
>>> netdev_priv will return a non NULL pointer even if the net_device
>>> is NULL & cause a crash without this fix.
>> Wrong. If net_device will be NULL hso_net_open won't get called.
>>
>>> Signed-off-by: Denis Joseph Barrow
>>> <D.Barow-x9gZzRpC1QbQT0dZR+AlfA-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org>
>>> ---
>>> Index: linux-2.6.27-rc3.patch/drivers/net/usb/hso.c
>>> ===================================================================
>>> --- linux-2.6.27-rc3.patch.orig/drivers/net/usb/hso.c    2008-08-20
>>> 12:12:28.000000000 +0200
>>> +++ linux-2.6.27-rc3.patch/drivers/net/usb/hso.c    2008-08-20
>>> 12:26:35.000000000 +0200
>>> @@ -611,14 +611,12 @@
>>>  /* called when net interface is brought up by ifconfig */
>>>  static int hso_net_open(struct net_device *net)
>>>  {
>>> -    struct hso_net *odev = netdev_priv(net);
>>> +    struct hso_net *odev;
>>>      unsigned long flags = 0;
>>>  
>>> -    if (!odev) {
>>> -        dev_err(&net->dev, "No net device !\n");
>>> +    if (!net)
>>>          return -ENODEV;
>>> -    }
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-usb" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
