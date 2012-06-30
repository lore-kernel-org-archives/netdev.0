From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: AF_BUS socket address family
Date: Sat, 30 Jun 2012 14:12:22 +0100
Message-ID: <20120630141222.60df95a5@pyramind.ukuu.org.uk>
References: <20120629231236.GA28593@mail.collabora.co.uk>
	<20120629.161821.948325645333976311.davem@davemloft.net>
	<20120629234230.GA11480@kyllikki.org>
	<20120629.165023.1605284574408858612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vincent.sanders@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120629.165023.1605284574408858612.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> What you really don't get is that packet drops and event losses are
> absolutely fundamental.

The world is full of "receiver reliable" multicast transport providers
which provide ordered defined message delivery properties.

They are reliable in the sense that a message is either queued to the
other ends or is not queued. They are not reliable in the sense of "we
wait forever".

In fact if you look up the stack you'll find a large number of multicast
messaging systems which do reliable transport built on top of IP. In fact
Red Hat provides a high level messaging cluster service that does exactly
this. (as well as dbus which does it on the deskop level) plus a ton of
stuff on top of that (JGroups etc)

Everybody at the application level has been using these 'receiver
reliable'  multicast services for years (Websphere MQ, TIBCO, RTPGM,
OpenPGM, MS-PGM, you name it). There are even accelerators for PGM based
protocols in things like Cisco routers and Solarflare can do much of it
on the card for 10Gbit.

> As long as receivers lack infinite receive queue this will always be
> the case.
> 
> Multicast operates in non-reliable transports only so that one stuck
> or malfunctioning receiver doesn't screw things over for everyone nor
> unduly brudon the sender.

All the world is not IP. Dealing with a malfunctioning receiver is
something dbus already has to deal with. "Unduly burden the sender" is
you talking out of your underwear. The sender is already implementing
this property set - in user space. So there can't be any more burdening,
in fact the point of this is to get rid of excess burdens caused by lack
of kernel support.

This is a latency issue not a throughput one so you can't hide it with
buffers. A few ms shaved off desktop behaviour here and there makes a
massive difference to perceived responsiveness. Less task switches and
daemons means a lot less tasks bouncing around processors which means
less power consumption.

Alan
