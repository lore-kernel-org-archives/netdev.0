From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: via_rhine modules error on 2.6.16 with mii-tool
Date: Thu, 13 Apr 2006 14:02:52 -0700
Message-ID: <20060413140252.1c22b078@localhost.localdomain>
References: <BAY103-F401F96F0B06D75E70AF0BFB2DF0@phx.gbl>
	<20060327203946.GA11824@k3.hellgate.ch>
	<20060413182638.GC25854@tuxdriver.com>
	<20060413114018.65fba555@localhost.localdomain>
	<20060413204731.GB2874@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Marco Berizzi <pupilla@hotmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:6119 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964959AbWDMVDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 17:03:15 -0400
To: Roger Luethi <rl@hellgate.ch>
In-Reply-To: <20060413204731.GB2874@k3.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Apr 2006 22:47:31 +0200
Roger Luethi <rl@hellgate.ch> wrote:

> On Thu, 13 Apr 2006 11:40:18 -0700, Stephen Hemminger wrote:
> > The right thing to do is get rid of the locking in via_rhine:netdev_ioctl
> > and push the locking down into mdio_read, mdio_write.
> 
> As I said before, a dozen other network drivers do the exact same thing --
> they call generic_mii_ioctl right after grabbing the private spin lock (and
> only one driver calls generic_mii_ioctl without taking the lock).
> 
>
> I am not keen on patches that make via-rhine more of a special case even if
> it was safe now; next thing you know generic_mii_ioctl is changed in a way
> that breaks the only driver that foolishly made assumptions about the
> side-effects of that function.
> 
> If you can safely move the locking down for all network drivers, that would
> be a different story, of course.
> 
> Roger

Didn't your mother ever tell you that just because everybody else does
it wrong, you don't have to.

The other drivers should be fixed as well.  Phy access with irq's disabled
is not good. The hardware I checked takes 100's of usecs to do one read
transaction.
