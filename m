From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [git patches] net driver fixes for 2.6.28-rc
Date: Tue, 4 Nov 2008 09:27:30 +0100
Message-ID: <4E748A76-E93F-40ED-B797-61F4A0CE7404@holtmann.org>
References: <20081104075138.GA2096@earth.li>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jonathan McDowell <noodles@earth.li>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54362 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753394AbYKDI1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 03:27:36 -0500
In-Reply-To: <20081104075138.GA2096@earth.li>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jonathan,

>>> are you also queuing patches for drivers/net/usb/hso.c, because the
>>> current state of that driver is fully broken. It oopses and shows up
>>> with a WLAN RFKILL switch instead of WWAN. Also it has some weird
>>> disconnect race with the TTY layer. Some patches have been posted,  
>>> but
>>> seems that nobody has picked them up so far.
>
>> Last patch sent me was sent on 9/16 by Denis Joseph Barrow; I replied
>> and never received a response after that.
>
>> Patches welcome...
>
>> I don't see any hso patches on
>> http://patchwork.ozlabs.org/project/netdev/list/ nor in my inbox,  
>> so I'm
>> guessing that no one sent me or netdev any hso patches.
>
> I sent the below to netdev@, Greg K-H and Andrew Bird (the people  
> listed
> in hso.c). I can't see it in the netdev archives but it did hit lkml  
> ok
> at:
>
> http://lkml.org/lkml/2008/10/30/92
>
> A subsequent fix for the rfkill layer has also been sent (and that did
> hit netdev ok and got acked), but this hso cleanup is still  
> appropriate.

It is not only appropriate, it is needed, because otherwise the driver  
is oopsing.

> The WLAN/WWAN change is obviously a one line fix but I didn't see any
> point sending a patch for it until I knew I was going to get some sort
> of response about it; I can knock one up if that's helpful.

Send a patch for it.

> Original message:
>
> [PATCH] Cleanup hso rfkill error handling
>
> Yup, this appears to be the problem, thanks. I think &hso_net->net- 
> >dev
> is more intuitive for the error message, so I've used that. I've also
> added missing line endings on the error messages and set our local
> rfkill structure element to NULL on failure so we don't try to call
> rfkill_unregister on driver removal if we failed to register at all.
>
> The patch below Works For Me (TM); the device is detected fine, can be
> removed without problems and connects ok. I'll have a prod at why the
> rfkill stuff isn't working next, but I believe this cleanup of the  
> error
> handling is appropriate no matter what the issue with registration is.
>
> Signed-Off-By: Jonathan McDowell <noodles@earth.li>

I have this patch running now and it works. Without it the device is  
not usable at all.

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel

