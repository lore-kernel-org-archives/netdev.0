From: Greg KH <greg@kroah.com>
Subject: Re: remove special ioctl from hso driver, replace by rfkill
Date: Thu, 17 Apr 2008 15:39:29 -0700
Message-ID: <20080417223929.GA31384@kroah.com>
References: <200804161428.18066.oliver@neukum.org> <4807C42F.9050409@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:37859 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237AbYDQWsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 18:48:43 -0400
Content-Disposition: inline
In-Reply-To: <4807C42F.9050409@teltonika.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 18, 2008 at 12:42:07AM +0300, Paulius Zaleckas wrote:
> Oliver Neukum wrote:
>>  /* called once for each interface upon device insertion */
>>  static int hso_probe(struct usb_interface *interface,
>>  		     const struct usb_device_id *id)
>>  {
>>  	int mux, i, if_num, port_spec;
>>  	unsigned char port_mask;
>> +	char *rfkn;
>>  	struct hso_device *hso_dev = NULL;
>>  	struct hso_shared_int *shared_int = NULL;
>>  	struct hso_device *tmp_dev = NULL;
>> @@ -2747,6 +2706,27 @@ static int hso_probe(struct usb_interfac
>>  		goto exit;
>>  	}
>>  +	hso_dev->rfkill = rfkill_allocate(&interface_to_usbdev(interface)->dev,
>> +				RFKILL_TYPE_WLAN);
>
> What will happen if rfkill is not enabled on kernel? I think HSO should
> not depend on rfkill. Solution should be to do #ifdef CONFIG_RFKILL..?

Ick, rfkill should degrade properly so that #ifdefs are not needed here.
I'll fix up rfkill.h to prevent this kind of dependancy requirement.

thanks,

greg k-h
