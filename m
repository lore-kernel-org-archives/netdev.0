From: <Mario_Limonciello@Dell.com>
Subject: RE: [PATCH v2] r8152: Add support for setting MAC to system's
 Auxiliary MAC address
Date: Fri, 3 Jun 2016 14:44:55 +0000
Message-ID: <b41e9c5664554909b7687fe745ed0312@ausx13mpc124.AMER.DELL.COM>
References: <1464886687-16284-1-git-send-email-mario_limonciello@dell.com>
 <1464886687-16284-2-git-send-email-mario_limonciello@dell.com>
 <20160602174808.GA32131@kroah.com>
 <2d81e70165b8447d92b873eafeaeded7@ausx13mpc124.AMER.DELL.COM>
 <20160602190238.GK15379@lunn.ch>
 <ae0f974692814260bb9f2f2cf4af6450@ausx13mpc124.AMER.DELL.COM>
 <20160602190946.GL15379@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <gregkh@linuxfoundation.org>, <hayeswang@realtek.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <pali.rohar@gmail.com>,
	<anthony.wong@canonical.com>
To: <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160602190946.GL15379@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Thursday, June 2, 2016 2:10 PM
> To: Limonciello, Mario <Mario_Limonciello@Dell.com>
> Cc: gregkh@linuxfoundation.org; hayeswang@realtek.com; linux-
> kernel@vger.kernel.org; netdev@vger.kernel.org; linux-
> usb@vger.kernel.org; pali.rohar@gmail.com; anthony.wong@canonical.com
> Subject: Re: [PATCH v2] r8152: Add support for setting MAC to system's
> Auxiliary MAC address
> 
> On Thu, Jun 02, 2016 at 07:04:32PM +0000, Mario_Limonciello@Dell.com
> wrote:
> > > -----Original Message-----
> > > From: Andrew Lunn [mailto:andrew@lunn.ch]
> > > Sent: Thursday, June 2, 2016 2:03 PM
> > > To: Limonciello, Mario <Mario_Limonciello@Dell.com>
> > > Cc: gregkh@linuxfoundation.org; hayeswang@realtek.com; linux-
> > > kernel@vger.kernel.org; netdev@vger.kernel.org; linux-
> > > usb@vger.kernel.org; pali.rohar@gmail.com;
> anthony.wong@canonical.com
> > > Subject: Re: [PATCH v2] r8152: Add support for setting MAC to system's
> > > Auxiliary MAC address
> > >
> > > > > And you want to check this for all Dell devices?  Please be model
> > > > > specific, I doubt a bunch of Dell servers wants to run this code...
> > > > >
> > > >
> > > > Tracking model specific is really going to turn into a giant list never
> ending
> > > list.
> > > > To drill down more specifically, I can match on chassis too.
> > >
> > > Does Dell happen to use its own USB Vendor ID for the USB device in
> > > the dock? You could go at this problem from the other direction if it
> > > does have a unique vendor ID.
> > >
> > >      Andrew
> >
> > Unfortunately it's not a Dell specific VID/PID.  I'm asking around to find out
> > if there is something else identifiable about this dock's NIC (maybe that
> r8152
> > can query).
> 
> lsusb -v
> 
> I assume there is a USB hub in the dock, maybe that has a Dell VID?
> Going one level up the USB tree hierarchy should not be too hard.
> 
>       Andrew

I confirmed with some internal contacts a few extra bits about questions 
about this from throughout the conversation.

1) This feature IS in the general Realtek driver for Windows, not a special Dell driver.
2) The feature only offered to the Realtek 8153-AD, no other Realtek chip will do it 
(even Realtek 8153-VB won't).
3) The feature is activated when a special "Docking" bit is set on the 8153-AD.
4) The feature is activated on all Realtek 8153-AD's on the host system with the
docking bit set.  So on Windows if two Dell docks were hooked up they would both 
have the same AUX MAC. 

So considering that I think it would make sense to only activate in those same
special circumstances (RTL8153-AD, docking bit set, system has \\_SB.AMAC).  
I also feel this should stay in the Realtek driver as this as this implementation is
very Realtek specific.
