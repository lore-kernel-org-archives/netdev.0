From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] lan78xx: Protect runtime_auto check by #ifdef CONFIG_PM
Date: Mon, 21 Mar 2016 19:51:09 +0100
Message-ID: <1458586269.9609.14.camel@suse.com>
References: <Pine.LNX.4.44L0.1603211415380.1708-100000@iolanthe.rowland.org>
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
In-Reply-To: <Pine.LNX.4.44L0.1603211415380.1708-100000@iolanthe.rowland.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-03-21 at 14:24 -0400, Alan Stern wrote:
> On Mon, 21 Mar 2016, Oliver Neukum wrote:
> 
> > On Mon, 2016-03-21 at 10:57 -0400, Alan Stern wrote:
> > 
> > > One possible solution is to export a sysfs parameter to prevent 
> > > statistics collection (or more generally, to change the interval at 
> > > which it occurs).
> > 
> > Surely, not performing a task can hardly be beaten in terms of power
> > consumption. That is not meant to be flippant, but I think these
> > issues are orthogonal. The question of how much to do doesn't
> > solve the question of doing efficiently what we do.
> 
> In other words, what's the best way to collect the statistics without 
> interfering with runtime PM, right?

Yes.

> If the device is suspended, presumably we know there's nothing to
> collect -- especially if we already collected the statistics at the
> time the device got suspended.  Hence my suggestion to avoid querying 
> the device while it is suspended.

That is perfectly alright if we just collect statistics.
As a generic mechanism it is bad. Think about the polling
for media detection.

> But this leaves open the issue that querying the device too often will 
> prevent it from going into autosuspend.  It seems to me that the best 
> way to deal with this is to make sure that the autosuspend timeout is 
> shorter than the interal between queries, not to make the querying 
> conditional on !runtime_auto.
[..]
> > If we know when the next activity will come, why not pass this
> > information down?

We have an autosuspend timeout because we think that IO, if it will
come at all, is likeliest to come soon. If, however, the IO is
periodic that heuristics is false.
To save most power the driver must either decide that the interval
is too short or suspend immediately. So if we are lucky enough
to have the frequency in the kernel, we should use that information.

	Regards
		Oliver
