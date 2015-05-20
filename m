From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [RESEND][PATCH] Bluetooth: Make request workqueue freezable
Date: Wed, 20 May 2015 11:46:31 +0200
Message-ID: <9BCD6CFF-0356-4A0F-97D4-776C0A2E436A@holtmann.org>
References: <s5hwq04zypv.wl-tiwai@suse.de> <Pine.LNX.4.44L0.1505191017460.1453-100000@iolanthe.rowland.org> <s5hpp5wtrrp.wl-tiwai@suse.de> <1432057375.3970.4.camel@suse.com> <s5h7fs3u5gy.wl-tiwai@suse.de> <1432111237.8287.3.camel@suse.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Takashi Iwai <tiwai@suse.de>, Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Laura Abbott <labbott@fedoraproject.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Laura Abbott <labbott@redhat.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	USB list <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432111237.8287.3.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Oliver,

>> The data is cached in RAM.  More specifically, the former loaded
>> firmware files are reloaded and saved at suspend for each device
>> object.  See fw_pm_notify() in firmware_class.c.
> 
> OK, this may be a stupid idea, but do we know the firmware
> was successfully loaded in the first place?
> Also btusb is in the habit of falling back to a generic
> firmware in some places. It seems to me that caching
> firmware is conceptually not enough, but we'd also need
> to record the absence of firmware images.

in a lot of cases the firmware is optional. The device will operate fine without the firmware. There are a few devices where the firmware is required, but for many it just contains patches.

It would be nice if we could tell request_firmware() if it is optional or mandatory firmware. Or if it should just cache the status of a missing firmware as well.

As long as the device in question gets disconnected and we run through the USB driver probe() callback again, the btusb.ko driver can not do anything smart in this case. It has to be done in request_firmware().

Regards

Marcel
