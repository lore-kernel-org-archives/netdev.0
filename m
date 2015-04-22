From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH 0/3] Enable connecting DSA-based switch to the USB
 RMII interface.
Date: Wed, 22 Apr 2015 18:39:10 +0200
Message-ID: <20150422163910.GO32294@lunn.ch>
References: <1429622791-7195-1-git-send-email-kaisrja1@fel.cvut.cz>
 <20150421124737.GD32294@lunn.ch>
 <55368667.5030105@gmail.com>
 <20150421173902.GL32294@lunn.ch>
 <55368E0B.8060600@gmail.com>
 <CAPnxhu7uFP1Moxg4b-=j36AMBNMSu64SkdhVWhh+Ab1R34fCow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Michal Sojka <sojkam1@fel.cvut.cz>,
	=?iso-8859-1?B?S29uZT8/bv0gVG9t4T8/?= <tkonecny@retia.cz>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jan Kaisrlik <kaisrja1@fel.cvut.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAPnxhu7uFP1Moxg4b-=j36AMBNMSu64SkdhVWhh+Ab1R34fCow@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 22, 2015 at 04:14:33PM +0000, Jan Kaisrlik wrote:
> 2015-04-21 17:51 GMT+00:00 Florian Fainelli <f.fainelli@gmail.com>:
> > On 21/04/15 10:39, Andrew Lunn wrote:
> >>>> I would however say that sysfs is the wrong API. The linux network
> >>>> stack uses netlink for most configuration activities. So i would
> >>>> suggest adding a netlink binding to DSA, and place the code in
> >>>> net/dsa/, not within an MDIO driver.
> >>>
> >>> I suppose we could do that, but that sounds like a pretty radical change
> >>> in how DSA is currently configured (that is statically at boot time),
> >>> part in order to allow booting from DSA-enabled network devices (e.g:
> >>> nfsroot).
> >>
> >> We would keep both DT and platform device. But statically at boot does
> >> not work for a USB hotpluggable switch!
> >
> > Is the switch really hotpluggable, or it is the USB-Ethernet adapter
> > connecting to it? If the former, then I agree, if not, I would imagine
> > that there is nothing that prevents creating the switch device first,
> > and wait for its "master_netdev" to show up later before it starts doing
> > anything useful?
> > --
> > Florian
> 
> Thank you for your quick and helpful answers.
> 
> The goal of this project is to extend embeded modules without integreted
> MII to add possibility to connect ethernet switch.
> 
> Current version of switch is hotplugable but this feature is not required.
> In my humble opinion, hotplugable switch seems to be pretty interesting idea.

Hi Jan

Thanks for the extra information.

I don't know this USB device. Can you change the product:vendor ID?
Could you imply from the USB product:vendor ID what the DSA
configuration is? So have a wrapper driver around the asix driver
which installs a dsa platform device and then instantiates the asix
driver? That eliminates all your DSA changes, no need for a user space
API, etc.

     Andrew
