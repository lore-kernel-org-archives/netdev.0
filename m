From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] lan78xx: Protect runtime_auto check by #ifdef CONFIG_PM
Date: Tue, 22 Mar 2016 10:50:09 +0100
Message-ID: <1458640209.1990.8.camel@suse.com>
References: <Pine.LNX.4.44L0.1603211527570.1708-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
	Woojung Huh <woojung.huh@microchip.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1603211527570.1708-100000@iolanthe.rowland.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-03-21 at 15:30 -0400, Alan Stern wrote:
> On Mon, 21 Mar 2016, Oliver Neukum wrote:
> 

> > We have an autosuspend timeout because we think that IO, if it will
> > come at all, is likeliest to come soon. If, however, the IO is
> > periodic that heuristics is false.
> > To save most power the driver must either decide that the interval
> > is too short or suspend immediately. So if we are lucky enough
> > to have the frequency in the kernel, we should use that information.
> 
> The autosuspend timeout is set by userspace.  The kernel may assign a

Thus it should apply to all IO originating in user space.
But only to that IO.

> default value, but the user can always override it.  Given this, I 
> don't see how the kernel can use frequency information (and I'm not 
> sure where that information would come from in the first place).

It can ignore internal IO for the purpose of the timeout.
If such IO is performed while the device is active, don't
alter the timer. Otherwise resume the device and look at
the provided hint and suspend again immediately if the period is long
enough.
If IO is generated periodically in the kernel, the kernel must know that
period.

	Regards
		Oliver
 
