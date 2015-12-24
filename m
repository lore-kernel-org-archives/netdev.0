From: Alan Stern <stern@rowland.harvard.edu>
Subject: RE: [PATCH v2] r8152: fix lockup when runtime PM is enabled
Date: Wed, 23 Dec 2015 20:32:03 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1512232026510.19895-100000@netrider.rowland.org>
References: <0835B3720019904CB8F7AA43166CEEB2F9547E@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Oliver Neukum <oneukum@suse.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"peter@lekensteyn.nl" <peter@lekensteyn.nl>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2F9547E@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Dec 2015, Hayes Wang wrote:

> Oliver Neukum [mailto:oneukum@suse.de]
> > Sent: Wednesday, December 23, 2015 4:20 PM
> [...]
> > No, step (2) does not exist. Calls to suspend() and [reset_]resume()
> > always balance. Usually a driver shouldn't care about system suspend.
> > The way the driver is currently coded will also fail for Port-Power Off.
> 
> It is different with Windows. The Windows would resume the device before
> system suspend, if the system suspend follows the autosuspend.
> 
> Would this be a problem? After system suspend, the device may wake up
> the system when receiving any packet, not only magic packet. The wake
> events are different for system suspend and autosuspend. However, I
> couldn't change the wake event, because the autosuspend occurs first,
> and the suspend() is only called once.

I don't understand why the wakeup conditions are different.  It seems
to me that the choice of which packets will generate a wakeup ought to
depend on the user's selection, not on the kind of suspend.  For
instance, if the user says that only a magic packet should cause a
wakeup then that should be true for both runtime suspend and system
suspend.

To put it another way, as far as the device is concerned a suspend is
just a suspend -- there's no different between a runtime suspend and a
system suspend.

Alan Stern
