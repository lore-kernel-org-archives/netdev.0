From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [linux-pm] [PATCH 0/4] Fix forcedeth hibernate/wake-on-lan
 problems
Date: Sat, 31 May 2008 22:51:19 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0805312247100.18240-100000@netrider.rowland.org>
References: <20080531221223.GA2630@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, <linux-kernel@vger.kernel.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Brownell <david-b@pacbell.net>,
	<linux-acpi@vger.kernel.org>, <linux-pm@lists.linux-foundation.org>
To: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20080531221223.GA2630@yamamaya.is-a-geek.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 1 Jun 2008, Tobias Diedrich wrote:

> Ok, after another long debugging session I finally found out the
> reason for the immediate reboot (after finding the place that
> suspends the serial console (drivers/pnp) and disabling that suspend
> path):
> The system is woken up by USB activity! (Optical mouse, anyone?)
> 
> Lo and behold:
> drivers/usb/core/hcd-pci.c tries it's best to activate 'wake on
> usb', which I didn't know since it apparently also never worked.
> However, after applying the 'use platform_enable_wakeup'-patch,
> not only forcedeth wake starts working, also usb wake.
> If I prevent usb wake:
> |echo disabled > /sys/devices/pci0000\:00/0000\:00\:02.0/power/wakeup'
> |echo disabled > /sys/devices/pci0000\:00/0000\:00\:02.1/power/wakeup'
> And then hibernate in platform mode, the immediate reboot is gone
> and waking up using magic packets works fine even without setting up
> /proc/acpi/wakeup first.
> 
> Maybe I should try hooking mouse and keyboard onto different usb
> host controllers, so I can disable wakeup for the mouse host
> controller and enable wakeup for the keyboard host controller,
> then it should be possible to wake the system by pressing a key. :)

You don't need to do that.  Wakeup can be set specifically for each 
individual USB device, provided CONFIG_USB_SUSPEND is enabled.


On Sun, 1 Jun 2008, Tobias Diedrich wrote:

> (BTW I first thought the 'immediate reboot because of usb wake' effect is
> caused by the optical mouse generating a wake event, but it rather
> seems to be a problem with a flaky secondary usb host controller,
> which sees a connected device where nothing is attached)

Can you provide debugging information (i.e., CONFIG_USB_DEBUG) with the 
details on this bogus wakeup?

Alan Stern


