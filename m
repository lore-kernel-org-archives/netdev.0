From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [RESEND][PATCH] Bluetooth: Make request workqueue freezable
Date: Wed, 20 May 2015 18:02:35 +0800
Message-ID: <CACVXFVOwYSEwRinYNKx5tUopCc6p9mKT_NszZs8=coo6W6k89w@mail.gmail.com>
References: <s5hwq04zypv.wl-tiwai@suse.de>
	<Pine.LNX.4.44L0.1505191017460.1453-100000@iolanthe.rowland.org>
	<s5hpp5wtrrp.wl-tiwai@suse.de>
	<1432057375.3970.4.camel@suse.com>
	<s5h7fs3u5gy.wl-tiwai@suse.de>
	<1432111237.8287.3.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Takashi Iwai <tiwai@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Laura Abbott <labbott@fedoraproject.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Laura Abbott <labbott@redhat.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432111237.8287.3.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 20, 2015 at 4:40 PM, Oliver Neukum <oneukum@suse.com> wrote:
> On Wed, 2015-05-20 at 08:29 +0200, Takashi Iwai wrote:
>> The data is cached in RAM.  More specifically, the former loaded
>> firmware files are reloaded and saved at suspend for each device
>> object.  See fw_pm_notify() in firmware_class.c.
>
> OK, this may be a stupid idea, but do we know the firmware
> was successfully loaded in the first place?

Yes, the firmware loader records that as device resource.
In reality, there won't be lots of devices requiring firmware
in one running system, so the idea of caching for every
successful loading is workable.

> Also btusb is in the habit of falling back to a generic
> firmware in some places. It seems to me that caching
> firmware is conceptually not enough, but we'd also need
> to record the absence of firmware images.

The caching can't cover the case which starts to load fw
during resume in the 1st time.

>
>         Regards
>                 Oliver
>
>
