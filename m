From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/3 v4] macvtap driver
Date: Thu, 11 Feb 2010 08:12:54 +0100
Message-ID: <201002110812.54224.arnd@arndb.de>
References: <201001271104.20607.arnd@arndb.de> <201002101550.14690.arnd@arndb.de> <9ae48b021002101642w752bbc93vbdcd71151dfb8cb7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org
To: Ed Swierk <eswierk@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:50801 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300Ab0BKHNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 02:13:17 -0500
In-Reply-To: <9ae48b021002101642w752bbc93vbdcd71151dfb8cb7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 11 February 2010 01:42:04 Ed Swierk wrote:
> On Wed, Feb 10, 2010 at 6:50 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> > I think we also need to ensure the device doesn't go away, which
> > was one of the reasons for the rcu_read_lock_bh() earlier.
> 
> This may be veering far off into the weeds, but I'm wondering if you
> considered making macvtap devices behave more like tap devices.
> Specifically, the application would open /dev/net/macvtap and send it
> an ioctl with the name of the macvtap interface, the name of the lower
> interface to attach to, the MAC address, etc; this would cause the
> macvtap interface to spring into existence. The macvtap interface
> would go away when the application exits or closes the file.

No, I never considered this. In fact, this behavior of tun/tap
is what makes that driver have really complex lifetime rules (more
so than macvtap) and causes all sorts of problems if you want to
manage unprivileged users accessing different outgoing interfaces.

> The tricky part here would be noticing when the lower interface goes
> away, and (ideally) reattaching when an interface with the same name
> reappears.

The first part is not so hard, the second part I'd rather not do.
 
> I think the advantage of this approach is that it better fits the way
> applications like qemu and libvirt use tap interfaces. Unlike the
> current approach, however, this wouldn't allow creating a macvtap
> interface and keep it around independently of the application using
> it. Is it desirable to support this use case?

I think it's very useful that you can set up static interfaces and give
them to a user (or group) that are then able to use these interfaces
without getting any network privileges beyond that.

Another reason for having one chardev per interface is to support
multiple open files for the same interface. I want to use that as
an easy way to support multi-queue NICs.

	Arnd
