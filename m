From: Ed Swierk <eswierk@aristanetworks.com>
Subject: Re: [PATCH 0/3 v4] macvtap driver
Date: Wed, 10 Feb 2010 16:42:04 -0800
Message-ID: <9ae48b021002101642w752bbc93vbdcd71151dfb8cb7@mail.gmail.com>
References: <201001271104.20607.arnd@arndb.de>
	 <1265655334.31760.9.camel@w-sridhar.beaverton.ibm.com>
	 <1265671815.6480.8.camel@localhost.localdomain>
	 <201002101550.14690.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f228.google.com ([209.85.219.228]:44055 "EHLO
	mail-ew0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199Ab0BKAmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 19:42:07 -0500
Received: by ewy28 with SMTP id 28so770345ewy.28
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 16:42:05 -0800 (PST)
In-Reply-To: <201002101550.14690.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 10, 2010 at 6:50 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> I think we also need to ensure the device doesn't go away, which
> was one of the reasons for the rcu_read_lock_bh() earlier.

This may be veering far off into the weeds, but I'm wondering if you
considered making macvtap devices behave more like tap devices.
Specifically, the application would open /dev/net/macvtap and send it
an ioctl with the name of the macvtap interface, the name of the lower
interface to attach to, the MAC address, etc; this would cause the
macvtap interface to spring into existence. The macvtap interface
would go away when the application exits or closes the file.

The tricky part here would be noticing when the lower interface goes
away, and (ideally) reattaching when an interface with the same name
reappears.

I think the advantage of this approach is that it better fits the way
applications like qemu and libvirt use tap interfaces. Unlike the
current approach, however, this wouldn't allow creating a macvtap
interface and keep it around independently of the application using
it. Is it desirable to support this use case?

--Ed
