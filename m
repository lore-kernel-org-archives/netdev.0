From: Alan Stern <stern@rowland.harvard.edu>
Subject: RE: [PATCH] lan78xx: Protect runtime_auto check by #ifdef CONFIG_PM
Date: Mon, 21 Mar 2016 15:27:00 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1603211523370.1708-100000@iolanthe.rowland.org>
References: <9235D6609DB808459E95D78E17F2E43D404CC166@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: oneukum@suse.com, <geert@linux-m68k.org>,
	<UNGLinuxDriver@microchip.com>, <davem@davemloft.net>,
	<linux@roeck-us.net>, <rjw@rjwysocki.net>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<linux-pm@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Woojung.Huh@microchip.com
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D404CC166@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Mar 2016 Woojung.Huh@microchip.com wrote:

> > But this leaves open the issue that querying the device too often will
> > prevent it from going into autosuspend.  It seems to me that the best
> > way to deal with this is to make sure that the autosuspend timeout is
> > shorter than the interal between queries, not to make the querying
> > conditional on !runtime_auto.
> 
> Short autosuspend timeout can affect performance. For instance our experiments showed that
> shorter than 10sec timeout made Ethernet performance degrade because of wakeup delays.
> So, just putting shorter timeout may have some side effects.

Sure.  This just means that you need a long statistics interval --
longer than the autosuspend timeout.  That's why I suggested making the
interval adjustable.

Alternatively, you could automatically set the statistics interval to
the autosuspend timeout (or 0 if autosuspend is disabled) plus some
fixed value.

Alan Stern

