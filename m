From: Rob Landley <rob@landley.net>
Subject: Re: [PATCHSET] printk, netconsole: implement reliable netconsole
Date: Sun, 19 Apr 2015 02:25:09 -0500
Message-ID: <CAOS_Y6Q=1YwsL3wijnNSGmZh-xa8DXjp4PLc-hPGXGd3acTuZA@mail.gmail.com>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33363 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbbDSHZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2015 03:25:10 -0400
Received: by paboj16 with SMTP id oj16so173362575pab.0
        for <netdev@vger.kernel.org>; Sun, 19 Apr 2015 00:25:10 -0700 (PDT)
In-Reply-To: <1429225433-11946-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2015 at 6:03 PM, Tejun Heo <tj@kernel.org> wrote:
> In a lot of configurations, netconsole is a useful way to collect
> system logs; however, all netconsole does is simply emitting UDP
> packets for the raw messages and there's no way for the receiver to
> find out whether the packets were lost and/or reordered in flight.

Except a modern nonsaturated LAN shouldn't do that.

If you have two machines plugged into a hub, and that's _all_ that's
plugged in, packets should never get dropped. This was the original
use case of netconsole was that the sender and the receiver were
plugged into the same router.

However, even on a quite active LAN the days of ethernet doing CDMA
requiring retransmits are long gone, even 100baseT routers have been
cacheing and retransmitting data internally so each connection can go
at the full 11 megabytes/second with the backplane running fast enough
to keep them all active at the same time. (That's why it's so hard to
find a _hub_ anymore, it's all routers. The point of routers is they
cache internally and send the packet only out the connection they
should go, based on an internal routing table because they listened to
incoming packets to figure out who lives where and do arp-like
things.)

And of course gigabit is a point to point protocol that has nothing to
do with conventional ethernet at _all_ other than the name, as far as
I know it can't _not_ do this.

So are you trying to program around a problem you've actually _seen_,
or are you attempting to reinvent TCP/IP yet again based on top of UDP
(Drink!) because of a purely theoretical issue?

Or are you trying to route netconsole, unencapsulated, across the
internet? Of course the internet itself refusing to drop packets but
instead buffering and retransmitting them even when doing so turns out
to be a really bad idea is sort of where this whole "bufferbloat"
thing came from. So again, even in that context, is this a problem
you've actually _seen_?

> printk already keeps log metadata which contains enough information to
> make netconsole reliable.  This patchset does the followings.

Adds a giant amount of complexity without quite explaining why.

Rob
