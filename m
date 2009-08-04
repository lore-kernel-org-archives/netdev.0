From: David VomLehn <dvomlehn@cisco.com>
Subject: [PATCH 0/7] initdev:kernel:Introduction to initdev synchronization
	patchset
Date: Tue, 4 Aug 2009 15:14:59 -0700
Message-ID: <20090804221459.GA9085@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-usb@vger.kernel.org,
	greg@kroah.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The kernel command line parameters "ip", "root", and "console" take devices
as arguments. These are termed "init devices" since devices specified by
these parameters are used during kernel initialization. Some init devices
take a long time to be discovered and made ready for use, USB devices being
a prime example. This patch provides two, related, functionalities:

o	Wait for device setup. Provides synchronization between use of
	init devices and their setup so that attempts to use them can be
	delayed until the devices are ready.
o	Prompt device wait termination. Terminates waits for device
	discovery as soon as it is know that no more devices remain to be
	discovered. For example, consider an embedded device that may or
	may not have a USB console. As soon as all USB devices have been
	discovered, there is no more need to wait for a console that isn't
	attached, and a headless system boot can continue.

This patch supports device discovery on USB and SCSI buses but provides a
framework for other bus types. Where possible, specific device types can
be specified so that, for example, waiting on a console does not prevent
mounting a root filesystem.

A secondary consequence of this patch is that the only remaining use of the
rootwait kernel parameter is to wait for a root device that is not plugged
in at boot.

This introduction is followed by 7 small-ish patches. It would be possible
to combine these but this patch touches the console, networking, and block
device areas and it is hoped that splitting the changes into smaller,
targeted chunks will make it easier for people in those areas to review it.
1	Basic initdev infrastructure
2	USB device discovery notification
3	Wait for console
4	Wait for network devices
5	USB and SCSI block device notification
6	Additional SCSI block device notification for asynchronous function
7	Wait for block device used for root

(Many thanks to Alan Stern, who said we could solve this without offensive
timeouts and then set about doing the integration into core USB and SCSI
code)

Signed-off-by: David VomLehn <dvomlehn@cisco.com>
---

