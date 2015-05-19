From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [RESEND][PATCH] Bluetooth: Make request workqueue freezable
Date: Tue, 19 May 2015 17:22:26 +0200
Message-ID: <E00D9D09-50A7-46C8-B141-9338F85B0020@holtmann.org>
References: <Pine.LNX.4.44L0.1505191017460.1453-100000@iolanthe.rowland.org>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Takashi Iwai <tiwai@suse.de>, Laura Abbott <labbott@redhat.com>,
	Laura Abbott <labbott@fedoraproject.org>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ming Lei <ming.lei@canonical.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	linux-usb@vger.kernel.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:45285 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932354AbbESPW2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 11:22:28 -0400
In-Reply-To: <Pine.LNX.4.44L0.1505191017460.1453-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alan,

>>>> I am not convinced. Now we are hacking the Bluetooth core layer
>>>> (which has nothing to do with the drivers suspend/resume or
>>>> probe) to do something different so that we do not see this
>>>> warning.
>>>> 
>>>> I can not do anything about the platform in question choosing a
>>>> unplug/replug for suspend/resume instead of having a proper USB
>>>> suspend and resume handling. That is pretty much out of our
>>>> control.
> 
> Actually one can do something about this.  I mean, one _can_ implement
> proper USB suspend and resume handling in the Bluetooth driver.  At
> this point the details aren't clear to me, but perhaps if the driver in
> question had a reset_resume callback then it might work better.

the btusb.ko driver has suspend/resume support. Are you saying we also need reset_resume support?

>>>> I would rather have the USB subsystem delay the probe()
>>>> callback if we tell it to.
> 
> This is possible.  I am not sure it would be the right thing to do,
> though.  What happens if the probe routine gets called early on during
> the boot-up procedure, before userspace is up and running?  The same
> thing should happen here.

For modules this will be hard. Since you need userspace before being able to load the modules. If built-in code, then in theory this might be possible. Depending on the order of the init sections.

>>>> Of just have request_firmware()
>>>> actually sleep until userspace is ready. Seriously, why is
>>>> request_firmware not just sleeping for us.
> 
> It won't work.  The request_firmware call is part of the probe 
> sequence, which in turn is part of the resume sequence.  Userspace 
> doesn't start running again until the resume sequence is finished.  If 
> request_firmware waited for userspace, it would hang.

Then I really have no idea on how to solve this unless we silence the warning from request_firmware. From a driver perspective we go back trough probe(). So the driver has to treat this as a new device.

Regards

Marcel
