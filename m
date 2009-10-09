From: Matt Domsch <matt_domsch@dell.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 9 Oct 2009 11:25:50 -0500
Message-ID: <20091009162550.GB20855@mock.linuxdev.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894F6@blrx3m08.blr.amer.dell.com> <20091009160442.GA21371@mock.linuxdev.us.dell.com> <20091009091247.0a9b60cb@nehalam>
Reply-To: Matt Domsch <Matt_Domsch@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Narendra K <Narendra_K@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, jordan_hargrave@dell.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:40909 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756974AbZJIQ03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 12:26:29 -0400
Content-Disposition: inline
In-Reply-To: <20091009091247.0a9b60cb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 09, 2009 at 09:12:47AM -0700, Stephen Hemminger wrote:
> On Fri, 9 Oct 2009 11:04:43 -0500
> Narendra K <Narendra_K@dell.com> wrote:
> 
> > By creating character devices for every network device, we can use
> > udev to maintain alternate naming policies for devices, including
> > additional names for the same device, without interfering with the
> > name that the kernel assigns a device.
> > 
> What happens if interface is renamed by either networking API:
>   ip li set dev eth0 name eth-renamed-by-me

udev sees a KOBJ_MOVE uevent.  Today it does not handle these events
at all, but talking with Kay, he believes udev can be extended to
handle that pretty easily.


> or via
>    mv /dev/net/eth0 /dev/net/eth-renamed-by-user

There is no VFS magic today such that this 'mv' will translate into a
device_rename() function inside the kernel.

udev "owns" the /dev/netdev/eth0 device node name.  If a user (root)
does a 'mv', the symlink referants will be broken.  This is no
different than doing so for a disk device or any other udev-managed
device node.  If someone does a
  mv /dev/sda /dev/sda-mybootdisk
and is relying on the /dev/disk/by-label/mybootdisk -> /dev/sda
symlink in some way, the application will fail.

> or if both are done at same time (what is locking model?)

There is no locking model.  udev will serialize the rename events
though, as seen in userspace.

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
