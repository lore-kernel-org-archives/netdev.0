From: dann frazier <dannf@hp.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Tue, 13 Oct 2009 09:08:39 -0600
Message-ID: <20091013150839.GD32107@ldl.fc.hp.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	matt_domsch@dell.com, jordan_hargrave@dell.com
To: Narendra K <narendra_k@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:10646 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759942AbZJMPJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 11:09:16 -0400
Content-Disposition: inline
In-Reply-To: <20091009140000.GA18765@mock.linuxdev.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 09, 2009 at 09:00:01AM -0500, Narendra K wrote:
> On Fri, Oct 09, 2009 at 07:12:07PM +0530, K, Narendra wrote:
> > > example udev config:
> > > SUBSYSTEM=="net",
> > SYMLINK+="net/by-mac/$sysfs{ifindex}.$sysfs{address}"
> > 
> > work as well.  But coupling the ifindex to the MAC address like this
> > doesn't work.  (In general, coupling any two unrelated attributes when
> > trying to do persistent names doesn't work.)
> > 
> Attaching the latest patch incorporating review comments.
> 
> By creating character devices for every network device, we can use
> udev to maintain alternate naming policies for devices, including
> additional names for the same device, without interfering with the
> name that the kernel assigns a device.
> 
> This is conditionalized on CONFIG_NET_CDEV.  If enabled (the default),
> device nodes will automatically be created in /dev/netdev/ for each
> network device.  (/dev/net/ is already populated by the tun device.)
> 
> These device nodes are not functional at the moment - open() returns
> -ENOSYS.  Their only purpose is to provide userspace with a kernel
> name to ifindex mapping, in a form that udev can easily manage.

If the idea is just to provide a userspace-visible mapping (and
presumably take advantage of udev's infrastructure for naming) does
this need kernel changes? Could this be a hierarchy under
e.g. /etc/udev instead, using plain text files? It still means we need
something like libnetdevname for apps to do the translation, but I'm
not seeing why it matters how this map is stored. Is there some
special property of the character devices (e.g. uevents) that we're
not already getting with the existing interfaces?

-- 
dann frazier

