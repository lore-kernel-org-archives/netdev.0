From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH net-next] cdc_ether: Improve ZTE MF823/831/910 handling
Date: Tue, 19 Jul 2016 13:06:36 +0200
Message-ID: <CAKfDRXjmmT53Abm9TgXtOUgOThiQ9+MMVB6_DkL1M2upNJG1Rw@mail.gmail.com>
References: <1468844691-8222-1-git-send-email-kristian.evensen@gmail.com>
 <1468846886.2280.6.camel@suse.com> <CAKfDRXiqDmJadXL4+v7saM431vPAp_8m8F0wvTkkYt-3tNjYyw@mail.gmail.com>
 <1468849802.2280.11.camel@suse.com> <CAKfDRXjaSz25_b8Na46DJEDvGUsZ-Xye+Rn2+o6Hy0EcuOopkA@mail.gmail.com>
 <1468851242.2280.14.camel@suse.com> <CAKfDRXiK82ULw7RnRGdFwzad8NOfnwZN0vqv=08Tf+cNSdyd2g@mail.gmail.com>
 <1468909209.2178.0.camel@suse.com> <CAKfDRXjzgd58kS-MzUsZAsD66VCa5=qyqaLr_eZSm-XphxA7Mw@mail.gmail.com>
 <52d1cd85-8bdc-c8ed-7a2c-460cefe7f0d5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Oliver Neukum <oneukum@suse.com>, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>
To: Lars Melin <larsm17@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34507 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698AbcGSLGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 07:06:39 -0400
In-Reply-To: <52d1cd85-8bdc-c8ed-7a2c-460cefe7f0d5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Lars,

On Tue, Jul 19, 2016 at 10:30 AM, Lars Melin <larsm17@gmail.com> wrote:
> On 2016-07-19 13:40, Kristian Evensen wrote:
>
>> I guess I can match on the VID/PID in usbnet, but won't it be cleaner
>> to add a new bind() function (in cdc_ether) which matches the two PIDs
>> and leave usbnet as is? Or am I misunderstanding how to add this
>> functionality to usbnet?
>>
>
> Matching on the usb id is probably not a great idea, there is more id's
> than the two you have found and there is also more than two non-unique mac
> addresses.
>
> Example:
>
> 0200FFAAAAAA  19d2:1589/1592/1595
> 020CE70B0102  19d2:1040/1048/1405
>
> You can easily find them by googling them, without colon separators you
> will find them in verbose lsusb listings, with colons you will find them in
> dmesg pastings.
>
> I would probably have found more dupes if users had refrained from using the
> stupid usbdevices cmd which removes almost all interesting info from device
> listings in internet foras.

Thanks for letting me know. It seems that the static MAC behaviour is
the default behaviour of ZTE-devices that use cdc_ether. Unless anyone
objects, I will make the following changes for v2:

* Create a ZTE-specific bind method in cdc_ether that checks for a
random MAC and generates a new MAC if found.
* Use the ZTE-specific bind + rx fixup for all ZTE cdc_ether devices
by default, and add exceptions if we find any devices not displaying
this behaviour. I see there are already five ZTE devices with separate
entries in the products-array in cdc_ether.

-Kristian
