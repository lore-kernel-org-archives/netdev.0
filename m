From: Greg KH <gregkh@suse.de>
Subject: Re: Converting network devices from class devices causes namespace pollution
Date: Sun, 18 Feb 2007 11:46:41 -0800
Message-ID: <20070218194641.GA9929@suse.de>
References: <m1lkiv8npz.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:57555 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751947AbXBRTsH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Feb 2007 14:48:07 -0500
Content-Disposition: inline
In-Reply-To: <m1lkiv8npz.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 18, 2007 at 08:55:20AM -0700, Eric W. Biederman wrote:
> 
> I believe the culprit is 43cb76d91ee85f579a69d42bc8efc08bac560278.
> 
> For some reason network devices are now showing up under the pci
> device tree, in directories that have something other than network
> devices.
> 
> # ls -l /sys/class/net/eth0
> lrwxrwxrwx 1 root root 0 Feb 17 23:19 /sys/class/net/eth0 -> ../../devices/pci0000:00/0000:00:0a.0/eth0
> 
> # ls /sys/devices/pci0000\:00/0000\:00\:0a.0/
> broken_parity_status  device  eth0        modalias  resource   subsystem         uevent
> class                 driver  irq         msi_bus   resource0  subsystem_device  vendor
> config                enable  local_cpus  power     resource1  subsystem_vendor

That's the PCI device directory where eth0 is attached to, what is wrong
with that?

> User space is allowed to rename network devices to anything any name
> not currently taken by another network device.
> 
> However when I now do something like:
> 
> ip link set eth0 name irq
> 
> The rename half happens (because it is legal), but sysfs can't support
> it because of the ridiculous directory eth0 is in.  After that
> point things go hideously wrong.

What goes wrong?  What is not renamed properly?

Oh, you can't rename it to something like "irq".  Well that's pretty
foolish on your behalf :)

> The current situation is hideous namespace pollution, and breaks user
> space, and is only likely only a matter of time before we have a
> reasonable instead of an strained conflict of names.

Do we really have a problem here?

> Is there any simple fix or do we need to revert the change away
> from class_device?

We need the class_device change to get suspend/resume working properly,
and to make a lot of other things better (unified device tree, smaller
kernel images, etc.)

But my main point remains, is this really a problem?  Do systems really
name their network devices with names that stop working with this change
today?  Distros use the mac address these days to name network devices
in a unique way, and that namespace does not conflict with the pci
attributes.

thanks,

greg k-h
