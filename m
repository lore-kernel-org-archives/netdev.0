From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: dm9601 as ethX or usbX?
Date: Mon, 20 Apr 2009 18:07:58 +0200
Message-ID: <873ac3wboh.fsf@macbook.be.48ers.dk>
References: <200904201457.37704.marcin@juszkiewicz.com.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Marcin Juszkiewicz <marcin@juszkiewicz.com.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:14608 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755917AbZDTQIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 12:08:02 -0400
Received: by ey-out-2122.google.com with SMTP id 9so142004eyd.37
        for <netdev@vger.kernel.org>; Mon, 20 Apr 2009 09:08:00 -0700 (PDT)
In-Reply-To: <200904201457.37704.marcin@juszkiewicz.com.pl> (Marcin Juszkiewicz's message of "Mon\, 20 Apr 2009 14\:57\:36 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Marcin" == Marcin Juszkiewicz <marcin@juszkiewicz.com.pl> writes:

Hi,

 Marcin> Is this normal behaviour of those adapters that ones with empty eeprom
 Marcin> ends as usbX?

Yes. The code in question is located in
drivers/net/usb/usbnet.c:usbnet_probe():

        strcpy (net->name, "usb%d");
...
                // heuristic:  "usb%d" for links we know are two-host,
                // else "eth%d" when there's reasonable doubt.  userspace
                // can rename the link if it knows better.
                if ((dev->driver_info->flags & FLAG_ETHER) != 0
                                && (net->dev_addr [0] & 0x02) == 0)
                        strcpy (net->name, "eth%d");


Bit 1 of the most significant byte of the MAC address specifies that
it's a locally generated (E.G. random) MAC address, which is what
dm9601.c will use if there's nothing specified in the EEPROM (or there
isn't any EEPROM connected).

 Marcin> I would prefer to have both as ethX as I use them in devices
 Marcin> where usbX as usually usb-gadget (g_ether) and as such usb0
 Marcin> is configured in total different scheme.

 Marcin> I know that one of options would be using udev and renaming
 Marcin> of interface but then I would have to remember to always copy
 Marcin> that rule to each device.

Sorry, other than that I don't know any other options (you could
ofcourse try to convince the usbnet maintainer to change the usbnet
logic, but it seems pretty sensible to me).

-- 
Bye, Peter Korsgaard
