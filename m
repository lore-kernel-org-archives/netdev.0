From: Roger Luethi <rl@hellgate.ch>
Subject: Re: via_rhine modules error on 2.6.16 with mii-tool
Date: Thu, 13 Apr 2006 22:47:31 +0200
Message-ID: <20060413204731.GB2874@k3.hellgate.ch>
References: <BAY103-F401F96F0B06D75E70AF0BFB2DF0@phx.gbl> <20060327203946.GA11824@k3.hellgate.ch> <20060413182638.GC25854@tuxdriver.com> <20060413114018.65fba555@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Marco Berizzi <pupilla@hotmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail14.bluewin.ch ([195.186.19.62]:14292 "EHLO
	mail14.bluewin.ch") by vger.kernel.org with ESMTP id S932465AbWDMUse
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 16:48:34 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060413114018.65fba555@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Apr 2006 11:40:18 -0700, Stephen Hemminger wrote:
> The right thing to do is get rid of the locking in via_rhine:netdev_ioctl
> and push the locking down into mdio_read, mdio_write.

As I said before, a dozen other network drivers do the exact same thing --
they call generic_mii_ioctl right after grabbing the private spin lock (and
only one driver calls generic_mii_ioctl without taking the lock).

I am not keen on patches that make via-rhine more of a special case even if
it was safe now; next thing you know generic_mii_ioctl is changed in a way
that breaks the only driver that foolishly made assumptions about the
side-effects of that function.

If you can safely move the locking down for all network drivers, that would
be a different story, of course.

Roger
