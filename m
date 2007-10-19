From: Chris Holvenstot <cholvenstot@comcast.net>
Subject: Re: Network failure with 2.6.23-git14
Date: Fri, 19 Oct 2007 13:28:47 -0500
Message-ID: <1192818527.6416.19.camel@localhost>
References: <1192790946.6416.4.camel@localhost>
	 <4718DB32.5000404@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rwcrmhc11.comcast.net ([216.148.227.151]:61751 "EHLO
	rwcrmhc11.comcast.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759584AbXJSSXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 14:23:50 -0400
In-Reply-To: <4718DB32.5000404@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-10-19 at 12:28 -0400, Jeff Garzik wrote:
> Chris Holvenstot wrote:
> > I built 2.6.23-git14 this morning - when booted I can not access the
> > network via my Ethernet connection.  Fallback to 2.6.23-git11 works OK.
> > One interesting message during boot:
> 
> > [   37.325760] forcedeth: Reverse Engineered nForce ethernet driver.
> > [   37.843618] forcedeth 0000:00:0a.0: ifname eth0, PHY OUI 0x5043 @ 1,
> > addr 00:19:db:6d:3f:1b
> > [   37.843623] forcedeth 0000:00:0a.0: highdma csum timirq gbit lnktim
> > desc-v3
> 
> > [   46.414433] sysfs: duplicate filename 'eth1' can not be created
> > [   46.414438] WARNING: at fs/sysfs/dir.c:424 sysfs_add_one()
> > [   46.414445]  [<c01ba80f>] sysfs_add_one+0x9f/0xe0
> > [   46.414456]  [<c01bb5c6>] sysfs_create_link+0x86/0x110
> > [   46.414462]  [<c025608a>] device_rename+0x17a/0x1e0
> > [   46.414467]  [<c0130190>] run_timer_softirq+0x30/0x180
> > [   46.414472]  [<c0287a60>] dev_change_name+0xb0/0x200
> > [   46.414476]  [<c0159a62>] filemap_fault+0x1f2/0x400
> > [   46.414478]  [<c012c895>] __do_softirq+0x75/0xf0
> > [   46.414484]  [<c027a260>] sock_ioctl+0x0/0x230
> > [   46.414487]  [<c028809c>] dev_ioctl+0x25c/0x520
> > [   46.414489]  [<c01646eb>] __do_fault+0x1ab/0x380
> > [   46.414494]  [<c0165d28>] handle_mm_fault+0xf8/0x610
> > [   46.414499]  [<c027a260>] sock_ioctl+0x0/0x230
> > [   46.414502]  [<c018343b>] do_ioctl+0x2b/0x90
> > [   46.414506]  [<c01834fc>] vfs_ioctl+0x5c/0x290
> > [   46.414510]  [<c0183798>] sys_ioctl+0x68/0x80
> > [   46.414513]  [<c01041de>] sysenter_past_esp+0x5f/0x85
> > [   46.414520]  =======================
> > [   46.414523] net eth1: device_rename: sysfs_create_symlink failed
> 
> 
> What are your network devices?  Is your problem with eth0, forcedeth, or 
> as this traceback implies, eth1?
> 
> What is eth1?  (driver, bus, ...)
> 
> Can you bisect?
> 
> 	Jeff
> 
> 

Jeff - 

You are correct, it is eth1 - which is the only hardware interface I
have available on the system.  It is implemented on the motherboard
using the Nvidia CK804 chip set.  My motherboard is an MSI product.

Attached at the end of this is an extract from an lshal command which I
hope will provide what you are looking for.

Bisect - I am willing to give it a try, but I see two problems.  

First, git12 was a dead dog on my system.  so what ever happened there
is not much of a spread between there and git14 which is where I am
having this problem.

BUT, I am willing to try if you are willing to do a little hand holding.

I have git 1.5.2.5 on my system.

I have NO git repository on my system no am I sure how to get it.  To
date the method I have been using is to download the newest patches on a
on a daily basis and work from there.

So, yes, I am willing to bisect, as long as you understand you may get a
few private, off-the-list emails asking for guidance.  

Chris

udi = '/org/freedesktop/Hal/devices/pci_10de_57'
  info.bus = 'pci'  (string)
  info.linux.driver = 'forcedeth'  (string)
  info.parent = '/org/freedesktop/Hal/devices/computer'  (string)
  info.product = 'CK804 Ethernet Controller'  (string)
  info.subsystem = 'pci'  (string)
  info.udi = '/org/freedesktop/Hal/devices/pci_10de_57'  (string)
  info.vendor = 'nVidia Corporation'  (string)
  linux.hotplug_type = 2  (0x2)  (int)
  linux.subsystem = 'pci'  (string)
  linux.sysfs_path = '/sys/devices/pci0000:00/0000:00:0a.0'  (string)
  pci.device_class = 6  (0x6)  (int)
  pci.device_protocol = 0  (0x0)  (int)
  pci.device_subclass = 128  (0x80)  (int)
  pci.linux.sysfs_path = '/sys/devices/pci0000:00/0000:00:0a.0'
(string)
  pci.product = 'CK804 Ethernet Controller'  (string)
  pci.product_id = 87  (0x57)  (int)
  pci.subsys_product_id = 28965  (0x7125)  (int)
  pci.subsys_vendor = 'Micro-Star International Co., Ltd.'  (string)
  pci.subsys_vendor_id = 5218  (0x1462)  (int)
  pci.vendor = 'nVidia Corporation'  (string)
  pci.vendor_id = 4318  (0x10de)  (int)

udi = '/org/freedesktop/Hal/devices/net_00_19_db_6d_3f_1b'
  info.capabilities = {'net', 'net.80203'} (string list)
  info.category = 'net.80203'  (string)
  info.parent = '/org/freedesktop/Hal/devices/pci_10de_57'  (string)
  info.product = 'Networking Interface'  (string)
  info.udi = '/org/freedesktop/Hal/devices/net_00_19_db_6d_3f_1b'
(string)
  linux.hotplug_type = 2  (0x2)  (int)
  linux.subsystem = 'net'  (string)
  linux.sysfs_path = '/sys/class/net/eth1'  (string)
  net.80203.mac_address = 111055552283  (0x19db6d3f1b)  (uint64)
  net.address = '00:19:db:6d:3f:1b'  (string)
  net.arp_proto_hw_id = 1  (0x1)  (int)
  net.interface = 'eth1'  (string)
  net.linux.ifindex = 2  (0x2)  (int)
  net.originating_device = '/org/freedesktop/Hal/devices/pci_10de_57'
(string)
  net.physical_device = '/org/freedesktop/Hal/devices/pci_10de_57'
(string)





> 

