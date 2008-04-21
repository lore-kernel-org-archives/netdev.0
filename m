From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: remove special ioctl from hso driver, replace by rfkill
Date: Mon, 21 Apr 2008 11:47:20 +0300
Message-ID: <480C5498.70309@teltonika.lt>
References: <200804161428.18066.oliver@neukum.org> <4808A88B.4010703@teltonika.lt> <20080418162513.GA6704@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:50282 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752994AbYDUIsJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 04:48:09 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Jnrh2-0008Rs-4w
	for netdev@vger.kernel.org; Mon, 21 Apr 2008 08:48:08 +0000
Received: from 82-135-208-232.static.zebra.lt ([82.135.208.232])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 08:48:08 +0000
Received: from paulius.zaleckas by 82-135-208-232.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 08:48:08 +0000
In-Reply-To: <20080418162513.GA6704@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH wrote:
> On Fri, Apr 18, 2008 at 04:56:27PM +0300, Paulius Zaleckas wrote:
>> Oliver Neukum wrote:
>>> Hi,
>>> could you test this patch?
>>> It does away with the one off serial ioctl replacing it with a standard
>>> mechanism.
>>> 	Regards
>>> 		Oliver
>> I have tested rfkill and it realy works, but there is two problems:
>>
>> - LED on the device doesn't indicate rf state... Maybe Filip knows
>>   some usb command to control it?
>>
>> - driver creates multiple rfkill entries on sysfs... This is because
>>   option device has multi endpoints (probe is called twice with GTM380):
> 
> You mean "multiple interfaces" :)

Yes, I think I meant it :)

> And that's correct, for this device, that is the way it was created, so
> either rfkill entry should work to shut off the radio...

Yes, both of them work, but there is a problem...
If you change state for one them, then another one remains not updated.
Also it doesn't make sense to have two rfkill entries for one device.
Maybe it should be created only with network device?

Paulius

