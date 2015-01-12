From: Rob Herring <robh@kernel.org>
Subject: Re: [RFC net-next 0/3] devconf: New infrastructure for setting pre-load parameters for a module
Date: Mon, 12 Jan 2015 21:02:20 +0000 (UTC)
Message-ID: <loom.20150112T214442-809@post.gmane.org>
References: <1420730220-20224-1-git-send-email-hadarh@mellanox.com> <20150108164618.GA11696@kroah.com> <54AEBA28.1030301@mellanox.com> <20150108174707.GA13218@kroah.com> <CAPcc5PivsUKr9Q3VN1NFn3xJiB339EdPV=DEiLie8d9QVgOmOg@mail.gmail.com> <20150108192513.GB1961@kroah.com> <CAPcc5PgyBh3Hn4_7kiche2VLFJRXGPUaBw1ycZgvXiR0TSToxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:45338 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750908AbbALVaK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2015 16:30:10 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1YAmYm-000508-J4
	for netdev@vger.kernel.org; Mon, 12 Jan 2015 22:30:04 +0100
Received: from 72-48-98-129.dyn.grandenetworks.net ([72.48.98.129])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 22:30:04 +0100
Received: from robh by 72-48-98-129.dyn.grandenetworks.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 22:30:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amir Vadai <amirv <at> mellanox.com> writes:
> On Thu, Jan 8, 2015 at 9:25 PM, Greg KH <gregkh <at> linuxfoundation.org> 
wrote:
> > On Thu, Jan 08, 2015 at 09:14:32PM +0200, Amir Vadai wrote:
> >> On Thu, Jan 8, 2015 at 7:47 PM, Greg KH <gregkh <at> 
linuxfoundation.org> wrote:
> >> > On Thu, Jan 08, 2015 at 07:11:04PM +0200, Amir Vadai wrote:
> >> >> On 1/8/2015 6:46 PM, Greg KH wrote:
> >> >> > On Thu, Jan 08, 2015 at 05:16:57PM +0200, Hadar Hen Zion wrote:
> >> >> >> Hi,
> >> >> >>
> >> >> >> When configuring a device at an early boot stage, most kernel 
drivers
> >> >> >> use module parameters (the parameters' settings can be determined 
in
> >> >> >> modprobe.d config files).
> >> >> >
> >> >> > Which is a bad idea, as you have learned :)
> 
> [...]
> 
> >
> > But you are talking about loading config info before the driver is
> > loaded, which goes backwards for how we automatically load modules when
> > the hardware is found.
> 
> I guess you're a busy man and getting tired of my nudges. And it is ok
> with us to make it a non-generic solution - so I won't bother you much
> more...
> I would like to understand the arguments here: Maybe there is a
> history that I missed - What are the arguments against having a config
> info before the driver is loaded? Assuming, that it will make the
> driver loading process simpler and faster.

DeviceTree does exactly this. Even discoverable buses sometimes need 
additional information. DT can be used to add additional properties to PCI 
devices for example. I'm not sure DT is a fit here. As a matter of policy to 
be OS independent, the configuration data should be tied to the hardware and 
not purely software configuration. The example of netdev vs. infiniband would 
fit, but I don't know about other cases. Traditionally, DT would be part of 
the firmware/bootloader rather than coupled to the kernel or distro. It is 
not clear to me in your case who does the configuration and when does it 
change. There is new support making its way into the kernel called DT 
overlays which allows loading additional DT data after or during boot. That 
may be a good fit for your use case.

Rob
