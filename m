From: Dave Young <hidave.darkstar@gmail.com>
Subject: Re: tty_register_device NULL pointer dereference in 2.6.31-rc4
Date: Thu, 30 Jul 2009 17:15:21 +0800
Message-ID: <a8e1da0907300215q3934da47g3676648e3b247af8@mail.gmail.com>
References: <4A6AD807.6060706@hartkopp.net>
	 <20090725115011.7ddf8d00@lxorguk.ukuu.org.uk>
	 <1248520053.28545.156.camel@violet>
	 <20090725131046.0f076f37@lxorguk.ukuu.org.uk>
	 <20090727095904.GA5442@darkstar> <4A6D8BA3.3030601@hartkopp.net>
	 <4A6D91D7.6030204@hartkopp.net> <20090727140736.GA1864@darkstar>
	 <4A705604.3040807@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-bluetooth@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:60603 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbZG3JPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 05:15:22 -0400
In-Reply-To: <4A705604.3040807@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2009 at 10:00 PM, Oliver Hartkopp<oliver@hartkopp.net> wrote:
> Dave Young wrote:
>> On Mon, Jul 27, 2009 at 01:39:03PM +0200, Oliver Hartkopp wrote:
>>> Oliver Hartkopp wrote:
>>>> Dave Young wrote:
>>>>> On Sat, Jul 25, 2009 at 01:10:46PM +0100, Alan Cox wrote:
>>>>>>>> tty_register_device appears to have been called with a NULL pointer. Not
>>>>>>>> sure why however.
>>>>>>> if that is the pointer for the struct device, then that used to be fine
>>>>>>> in the past. Not all RFCOMM device have a parent when they are created.
>>>>>> The tty layer doesn't care about the struct device really. Nothing there
>>>>>> has changed. The NULL passed appears to be the driver argument.
>>>>> Agree with you, because in rfcomm_init, rfcomm thread run before tty initilized, the following patch may fix the problem.
>>>>> oliver, could you verify it it fix your problem?
>>>> Hi Dave,
>>>>
>>>> i get this problem really seldom on my Laptop and i did not manage to get a
>>>> reproducible Oops of that problem.
>>>>
>>>> Anyway the code you are pointing to seems to have a problem and your added
>>>> error handling looks good to me - even if i don't know if the initializations
>>>> can be reordered in that way.
>>>>
>>>> I'll try your patch, but it could take a *long* time to prove it right ;-)
>>>>
>>> Just FYI:
>>>
>>> Your patch compiled, the system booted without problems and nothing is broken
>>> so far. I checked the BT, WLAN and BT dial-up with success. So it looks good
>>> to me.
>>
>> Thanks for the testing. Marcel, could you take a look?
>
> Hi Dave,
>
> i got it again - even with your patch (that's why it's 2.6.31-rc4-dirty in the
> attached screenshot).

Weird, the oops occurs between sock init and tty init routines. Could
you tell your bluez version and your configuration?

-- 
Regards
dave
