From: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v8 0/8] thunderbolt: Introducing Thunderbolt(TM)
 Networking
Date: Fri, 30 Sep 2016 10:50:21 +0200
Message-ID: <20160930085021.GA10451@kroah.com>
References: <1475073870-2126-1-git-send-email-amir.jer.levy@intel.com>
 <20160930.015555.2177533749954623343.davem@davemloft.net>
 <20160930063005.GA7571@kroah.com>
 <20160930.024026.274720546666401005.davem@davemloft.net>
 <E607265CB020454880711A6F96C05A03AB7CF632@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        "andreas.noever@gmail.com" <andreas.noever@gmail.com>,
        "bhelgaas@google.com" <bhelgaas@google.com>,
        "corbet@lwn.net" <corbet@lwn.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
        "mario_limonciello@dell.com" <mario_limonciello@dell.com>,
        thunderbolt-linux <thunderbolt-linux@intel.com>,
        "Westerberg, Mika" <mika.westerberg@intel.com>,
        "Winkler, Tomas" <tomas.winkler@intel.com>,
        "Zhang, Xiong Y" <xiong.y.zhang@intel.com>
To: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E607265CB020454880711A6F96C05A03AB7CF632@hasmsx107.ger.corp.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 30, 2016 at 08:37:36AM +0000, Levy, Amir (Jer) wrote:
> On Fri, Sep 30 2016, 09:40 AM, David Miller wrote:
> > From: Greg KH <gregkh@linuxfoundation.org>
> > Date: Fri, 30 Sep 2016 08:30:05 +0200
> > 
> > > On Fri, Sep 30, 2016 at 01:55:55AM -0400, David Miller wrote:
> > >> From: Amir Levy <amir.jer.levy@intel.com>
> > >> Date: Wed, 28 Sep 2016 17:44:22 +0300
> > >>
> > >> > This driver enables Thunderbolt Networking on non-Apple platforms
> > >> > running Linux.
> > >>
> > >> Greg, any idea where this should get merged once fully vetted?  I can
> > >> take it through the net-next tree, but I'm fine with another more
> > >> appropriate tree taking it as well.
> > >
> > > I am supposed to be taking thunderbolt patches, but if this really is
> > > a network driver, it should go under drivers/net/ somewhere.  It needs
> > > more review though, it's not ready to go through anyone's tree just
> > > yet :)
> > >
> > > I'll let the thunderbolt maintainer go through it first before asking
> > > for a netdev review.
> > 
> > Ok, thanks Greg.
> 
> Greg, David,
> Andreas replied to similar request on patch v6:
> "This driver is independent from mine. It uses an interface provided
> by the firmware which is not present on Apple hardware and with which
> I am not familiar (also it does networking, not pci with which I am
> also not familiar). So I cannot comment on the driver itself. I don't
> mind a second driver, if that is what you are asking."

Yes, but I still need an ack from the thunderbolt maintainer that you
aren't doing anything foolish with that interface before I can take the
code.

> Note that Thunderbolt Networking is the first feature we would like to
> submit, but the next features aren't related to network, but more to
> Thunderbolt functionality. 

If this really is a real network device, it should probably live in
drivers/net/ like other network drivers.

> This is the reason I created the directory thunderbolt/icm, since the
> next features requires ICM to be enabled as well.

As long as you have ICM split out so that other drivers can use it, it
should be fine, no matter where in the tree it lives, right?

> I also followed the firewire as example that includes net.c (in
> drivers/firewire directory) along with other firewire functionality. 

That's the old-style of placing files.  We have moved the USB network
drivers out of drivers/usb/ a while ago.  The current thought is to
group drivers of specific types, not busses, together wherever possible,
as that is usually the majority of the logic in the driver (i.e. a USB
network driver has more network-driver specific logic than USB-specific
logic.)

Hope this helps explain things.  I'll get to your patches next week,
they are in my queue at the moment, but have conferences to deal with at
the moment.  Don't let my delay stop you from working on further "ICM"
drivers if needed, you can always send new series of patches that build
on this one when you have it ready.

thanks,

greg k-h
