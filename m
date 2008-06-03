From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [linux-pm] [PATCH 0/4] Fix forcedeth hibernate/wake-on-lan
 problems
Date: Tue, 3 Jun 2008 16:06:10 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0806031603410.3524-100000@iolanthe.rowland.org>
References: <20080603173013.GA9490@yamamaya.is-a-geek.org>
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
In-Reply-To: <20080603173013.GA9490@yamamaya.is-a-geek.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Jun 2008, Tobias Diedrich wrote:

> > So for some reason your EHCI controller thinks a wakeup event is 
> > pending.  This means you should examine the contents of the "registers" 
> > file in the debugfs directory for the EHCI controller, not OHCI.
> 
> melchior:/mnt/ehci/0000:00:02.1# cat registers
> bus pci, device 0000:00:02.1 (driver 10 Dec 2004)
> EHCI Host Controller
> EHCI 1.00, hcd state 1
> ownership 00000001
> SMI sts/enable 0xc0080000
> structural params 0x00101a8a
> capability params 0x0000a086
> status 0008 FLR
> command 010009 (park)=0 ithresh=1 period=256 RUN
> intrenable 37 IAA FATAL PCD ERR INT
> uframe 3f3a
> port 1 status 003400 POWER OWNER sig=k
> port 2 status 001000 POWER sig=se0
> port 3 status 003400 POWER OWNER sig=k
> port 4 status 003400 POWER OWNER sig=k
> port 5 status 001000 POWER sig=se0
> port 6 status 001000 POWER sig=se0
> port 7 status 001000 POWER sig=se0
> port 8 status 001000 POWER sig=se0
> port 9 status 001000 POWER sig=se0
> port 10 status 001000 POWER sig=se0
> irq normal 0 err 0 reclaim 0 (lost 0)
> complete 0 unlink 0

Got to admit, I'm stumped.  There's nothing in the state description to 
indicate why the controller should want to signal a wakeup event.

As an experiment, you could try disabling wakeup on the EHCI controller 
alone, leaving it enabled on the OHCI controller.  Since the keyboard 
-- and in fact all your USB devices -- is attached to the OHCI 
controller, it should do what you want.

Alan Stern

