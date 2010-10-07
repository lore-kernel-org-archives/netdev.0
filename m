From: <Narendra_K@Dell.com>
Subject: Re: [PATCH V2] Use firmware provided index to register a network
 interface
Date: Thu, 7 Oct 2010 11:44:57 -0700
Message-ID: <20101007184440.GA2999@libnet-test.oslab.blr.amer.dell.com>
References: <20101007142319.GB2641@libnet-test.oslab.blr.amer.dell.com>
 <20101007151134.GA25713@kroah.com>
 <20101007163113.GA14260@auslistsprd01.us.dell.com>
 <20101007164835.GA27339@kroah.com>
 <AANLkTinP5WPDPvk+kq8vsyP=xC9qcoe+c=1EBp0XJNPk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <greg@kroah.com>, <Matt_Domsch@Dell.com>, <netdev@vger.kernel.org>,
	<linux-hotplug@vger.kernel.org>, <linux-pci@vger.kernel.org>,
	<Jordan_Hargrave@Dell.com>, <Vijay_Nijhawan@Dell.com>,
	<Charles_Rose@Dell.com>
To: <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:36191 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079Ab0JGStY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 14:49:24 -0400
In-Reply-To: <AANLkTinP5WPDPvk+kq8vsyP=xC9qcoe+c=1EBp0XJNPk@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 07, 2010 at 10:35:14PM +0530, Kay Sievers wrote:
>    On Thu, Oct 7, 2010 at 18:48, Greg KH <greg@kroah.com> wrote:
>    > On Thu, Oct 07, 2010 at 11:31:13AM -0500, Matt Domsch wrote:
>    >> 1) SMBIOS type 41 method.  Windows does not use this today, and I
>    >>    can't speak to their future plans.  Narendra's kernel patch does,
>    >>    as has biosdevname, the udev helper we first wrote for this
>    >>    purpose, for several years.
>    >
>    > Then stick with that udev helper please :)
> 
>    What about just exporting this information in sysfs, and not touch the
>    naming?
> 
>    Anyway, I'm pretty sure all of this naming of onboard devices should
>    happen only at install time, or from a system management tool and not
>    at hotplug time.
> 
>    We should not get confused by the way the (very simple)
>    automatic-rule-creater for persistent netdev naming in udev works.
>    This is really just a tool for the common case, and works fine for the
>    majority of people.

Right. It works as the automatic rule creator saves the snapshot of the
registered network interfaces at run time. 

> 
>    I'm not sure, if we should put all these special use cases in the
>    hotplug path. I mean it's not that people add and remove 4 port
>    network cards with special BIOS all the time, and expect proper naming
>    on the first bootup, right? The installer, or the system management
>    tool could just create/edit udev rules to provide proper device naming
>    on whatever property is available at a specific hardware, be it the
>    MAC address or some other persistent match?
> 

The proposal made is not expecting deterministic naming when an add-in
card with 'N' ports is plugged in/out. It is specific to onboard devices
only. Expectation is onboard devices have deterministic naming at first
bootup. And no special BIOS required as SMBIOS tables are in use for
sometime now.

I did explore using rules based on the exported attribute ATTRS{index}
on a system with 4 Onboard devices and two add-in devices.(where add-in
device becomes eth0 and eth1)

# PCI device 0x14e4:0x164c (bnx2) (custom name provided by external
# tool) SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",
# ATTRS{index}=="1", ATTR{type}=="1", KERNEL=="eth*", NAME="eth0"

(and similary for eth1..eth3)

And for add-in devices.

# PCI device 0x8086:0x10c9 (igb) (custom name provided by external tool)
# SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",
# ATTR{address}=="00:1b:21:54:33:3c", ATTR{type}=="1", KERNEL=="eth*",
# NAME="eth4" (and similar for eth5 as they do not have an index)

This works as i edited the file manually.

If this has to be done on a large number of systems where an image
based deployment is preferred, getting onboard device names as expected
is an issue and is important.

-- 
With regards,
Narendra K
