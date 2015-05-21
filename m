From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [RESEND][PATCH] Bluetooth: Make request workqueue freezable
Date: Thu, 21 May 2015 16:39:16 +0200
Message-ID: <33C25745-6839-4858-9A3E-19EC6408ECED@holtmann.org>
References: <Pine.LNX.4.44L0.1505211009240.1397-100000@iolanthe.rowland.org>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Takashi Iwai <tiwai@suse.de>, Laura Abbott <labbott@redhat.com>,
	Oliver Neukum <oneukum@suse.com>,
	Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Laura Abbott <labbott@fedoraproject.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	USB list <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1505211009240.1397-100000@iolanthe.rowland.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alan,

>> Then avoiding the failed firmware is no solution, indeed.
>> If it's a new probe, it should be never executed during resume.
> 
> Can you expand this comment?  What's wrong with probing during resume?
> 
> The USB stack does carry out probes during resume under certain
> circumstances.  A driver lacking a reset_resume callback is one of
> those circumstances.

in case the platform kills the power to the USB lines, we can never do anything about this. I do not want to hack around this in the driver.

What are the cases where we should implement reset_resume and would it really help here. Since the btusb.ko driver implements suspend/resume support, would reset_resume ever be called?

However I get the feeling someone needs to go back and see if the device is the same one and just gets probed again or if it is a new one from the USB host stack perspective.

Regards

Marcel
