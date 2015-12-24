From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH v2] r8152: fix lockup when runtime PM is enabled
Date: Thu, 24 Dec 2015 11:08:38 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1512241100490.2785-100000@netrider.rowland.org>
References: <1450972034.28243.18.camel@suse.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "peter@lekensteyn.nl" <peter@lekensteyn.nl>,
	Hayes Wang <hayeswang@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450972034.28243.18.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 24 Dec 2015, Oliver Neukum wrote:

> On Thu, 2015-12-24 at 10:14 -0500, Alan Stern wrote:
> > On Thu, 24 Dec 2015, Oliver Neukum wrote:
> > 
> > > On Wed, 2015-12-23 at 20:32 -0500, Alan Stern wrote:
> 
> > > But you cannot keep that setting if the system goes down
> > > or any broadcast packet would resume the whole system.
> > > Yet you cannot just disable remote wake up, as WoL packages
> > > still must trigger a remote wake up.
> > 
> > This means that sometimes you want to avoid losing packets and other 
> > times you do want to lose packets.  That is a policy decision, and 
> > therefore it should be made by the user, not the kernel.
> 
> Indeed it is and there is a tool for this with a defined
> interface called "ethtool"

No; ethtool affects the wakeup setting for system suspend, but not
for runtime suspend.  I was referring to something that would specify 
the setting for both cases.  But perhaps that doesn't make sense, 
because you never want to drop relevant packets during runtime suspend.  
If you did, you would run "ifconfig down" instead.

> > the PM core aren't adequate for what the driver needs.  The PM core 
> > distinguishes between wakeup enabled or disabled; it doesn't 
> > distinguish among different levels of wakekup.
> 
> True and sanely it cannot. We could only distinguish between drivers
> which need their devices to be resumed before the system suspends and
> the rest.
> Or we tell driver coders to use the notifier chains.

"Resume before system suspend" sounds like a reasonable thing to
implement, for devices that have multiple levels of wakeup settings.  
Would you like to post a proposal on linux-pm for this?

Alan Stern
