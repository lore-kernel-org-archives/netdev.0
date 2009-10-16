From: dann frazier <dannf@hp.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Thu, 15 Oct 2009 18:32:45 -0600
Message-ID: <20091016003245.GD29672@ldl.fc.hp.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
 <20091013150839.GD32107@ldl.fc.hp.com>
 <EDA0A4495861324DA2618B4C45DCB3EE58954D@blrx3m08.blr.amer.dell.com>
 <20091013173638.GE1119@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Matt_Domsch@Dell.com, Jordan_Hargrave@Dell.com,
	Charles_Rose@Dell.com
To: Narendra_K@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:43375 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758841AbZJPAeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 20:34:05 -0400
Content-Disposition: inline
In-Reply-To: <20091013173638.GE1119@ldl.fc.hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 13, 2009 at 11:36:38AM -0600, dann frazier wrote:
> 1;2202;0cOn Tue, Oct 13, 2009 at 10:43:49PM +0530, Narendra_K@Dell.com wrote:
> > 
> > >> These device nodes are not functional at the moment - open() returns 
> > >> -ENOSYS.  Their only purpose is to provide userspace with a kernel 
> > >> name to ifindex mapping, in a form that udev can easily manage.
> > >
> > >If the idea is just to provide a userspace-visible mapping 
> > >(and presumably take advantage of udev's infrastructure for 
> > >naming) does this need kernel changes? Could this be a 
> > >hierarchy under e.g. /etc/udev instead, using plain text 
> > >files? It still means we need something like libnetdevname for 
> > >apps to do the translation, but I'm not seeing why it matters 
> > >how this map is stored. Is there some special property of the 
> > >character devices (e.g. uevents) that we're not already 
> > >getting with the existing interfaces?
> > 
> > Yes. The char device by itself doesn't help in any way. But it provides
> > a flexible mechanism to provide multiple names for the same device, just
> > the way it is for disks.
> 
> Right - so any reason this couldn't be implemented completely in
> userspace by having udev manipulate plain text files under say
> /etc/udev/net/?
> 
> I do agree that it would be nice for admins/installers to tweak/use
> nic names in a similar way to storage names (udev rules), and it might
> let us take advantage of a lot of the existing udev code.

Is there interest in this approach?

 - modify udev to manage network devices names as regular (non-device)
   files (stored in /etc/udev, /dev/netdev, or wherever)
 - use the existing udev rules to manage symlinks to these files
 - point libnetdevname at these text files for its name resolution

I've started prototyping this, and it certainly looks possible w/o any
kernel changes. However, I could probably use some advice from a udev
person to do a proper implementation.

-- 
dann frazier

