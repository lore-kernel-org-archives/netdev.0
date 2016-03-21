From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] lan78xx: Protect runtime_auto check by #ifdef CONFIG_PM
Date: Mon, 21 Mar 2016 15:30:56 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1603211527570.1708-100000@iolanthe.rowland.org>
References: <1458586269.9609.14.camel@suse.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
	Woojung Huh <woojung.huh@microchip.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Guenter Roeck <linux@roeck-us.net>,
	<linux-kernel@vger.kernel.org>, <linux-pm@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458586269.9609.14.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Mar 2016, Oliver Neukum wrote:

> On Mon, 2016-03-21 at 14:24 -0400, Alan Stern wrote:
> > On Mon, 21 Mar 2016, Oliver Neukum wrote:
> > 
> > > On Mon, 2016-03-21 at 10:57 -0400, Alan Stern wrote:
> > > 
> > > > One possible solution is to export a sysfs parameter to prevent 
> > > > statistics collection (or more generally, to change the interval at 
> > > > which it occurs).
> > > 
> > > Surely, not performing a task can hardly be beaten in terms of power
> > > consumption. That is not meant to be flippant, but I think these
> > > issues are orthogonal. The question of how much to do doesn't
> > > solve the question of doing efficiently what we do.
> > 
> > In other words, what's the best way to collect the statistics without 
> > interfering with runtime PM, right?
> 
> Yes.
> 
> > If the device is suspended, presumably we know there's nothing to
> > collect -- especially if we already collected the statistics at the
> > time the device got suspended.  Hence my suggestion to avoid querying 
> > the device while it is suspended.
> 
> That is perfectly alright if we just collect statistics.
> As a generic mechanism it is bad. Think about the polling
> for media detection.

True.  Here I'm talking specifically about collecting statistics.  
Media detection has its own requirements.

> > But this leaves open the issue that querying the device too often will 
> > prevent it from going into autosuspend.  It seems to me that the best 
> > way to deal with this is to make sure that the autosuspend timeout is 
> > shorter than the interal between queries, not to make the querying 
> > conditional on !runtime_auto.
> [..]
> > > If we know when the next activity will come, why not pass this
> > > information down?
> 
> We have an autosuspend timeout because we think that IO, if it will
> come at all, is likeliest to come soon. If, however, the IO is
> periodic that heuristics is false.
> To save most power the driver must either decide that the interval
> is too short or suspend immediately. So if we are lucky enough
> to have the frequency in the kernel, we should use that information.

The autosuspend timeout is set by userspace.  The kernel may assign a 
default value, but the user can always override it.  Given this, I 
don't see how the kernel can use frequency information (and I'm not 
sure where that information would come from in the first place).

Alan Stern
