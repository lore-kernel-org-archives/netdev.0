From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] lan78xx: Protect runtime_auto check by #ifdef CONFIG_PM
Date: Mon, 21 Mar 2016 14:24:07 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1603211415380.1708-100000@iolanthe.rowland.org>
References: <1458581670.9609.5.camel@suse.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Woojung Huh <woojung.huh@microchip.com>,
	Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <linux-pm@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <1458581670.9609.5.camel@suse.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Mar 2016, Oliver Neukum wrote:

> On Mon, 2016-03-21 at 10:57 -0400, Alan Stern wrote:
> 
> > One possible solution is to export a sysfs parameter to prevent 
> > statistics collection (or more generally, to change the interval at 
> > which it occurs).
> 
> Surely, not performing a task can hardly be beaten in terms of power
> consumption. That is not meant to be flippant, but I think these
> issues are orthogonal. The question of how much to do doesn't
> solve the question of doing efficiently what we do.

In other words, what's the best way to collect the statistics without 
interfering with runtime PM, right?

If the device is suspended, presumably we know there's nothing to
collect -- especially if we already collected the statistics at the
time the device got suspended.  Hence my suggestion to avoid querying 
the device while it is suspended.

But this leaves open the issue that querying the device too often will 
prevent it from going into autosuspend.  It seems to me that the best 
way to deal with this is to make sure that the autosuspend timeout is 
shorter than the interal between queries, not to make the querying 
conditional on !runtime_auto.

> > But checking the runtime_auto flag is probably not a great idea.  Even
> > if it isn't set, collecting statistics is likely to wait up a device
> > that otherwise would have remained suspended.
> > 
> > Perhaps the best solution is to collect the statistics only when the 
> > device is not suspended or is about to suspend.
> 
> If we know when the next activity will come, why not pass this
> information down?

I don't follow.

Alan Stern

