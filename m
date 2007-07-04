From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: 04 Jul 2007 13:37:23 +0200
Message-ID: <ygfzm2ciemk.fsf@janus.isnogud.escape.de>
References: <20070622034452.28886.0@janus.isnogud.escape.de>
	<20070622034703.28886.5@janus.isnogud.escape.de>
	<467BAC48.1070700@trash.net> <ygfk5tw41rq.fsf@janus.isnogud.escape.de>
	<467BC2AF.8080901@trash.net> <467D0C97.1000000@hartkopp.net>
	<467D178B.8080503@trash.net> <467D3891.4010906@hartkopp.net>
	<467D4965.40601@trash.net> <467D4D65.2080806@hartkopp.net>
	<467D54AB.5010407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	David Miller <davem@davemloft.net>, j.hadi123@gmail.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:49159 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757328AbXGDLlD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 07:41:03 -0400
In-Reply-To: <467D54AB.5010407@trash.net>; from Patrick McHardy on Sat, 23 Jun 2007 19:13:15 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> It should create as many devices as necessary to operate (similar
> to the loopback device) by default. Optional interfaces that are
> used for addressing reasons should be manually added by the user
> as needed. And it should not use module parameters for that please.

I have now changed vcan to use the netlink interface.  I am now
thinking about how many interfaces should be created at module load
time.

The PF_CAN doesn't need vcan to operate, like lo for IP.  vcan is
mostly for doing tests when you don't have real CAN interfaces
available, and you would normally want to have as many vcan devices as
you would have real CAN interface on your target hardware.

This is why I also wanted to have a default of 0 vcan interfaces and
an ioctl do add interfaces as needed.  Then we decided however to have
a module parameter with a typical default and no ioctl().

Now, I would again think that 0 vcan interfaces should be created
automatically and the user must create the devices he needs.  Wouldn't
that also be a better default for dummy interfaces?  It would simplify
dummy.c quite a bit, since dummy_init_one() could be removed
completely and dummy_init_module() would only register the
dummy_link_ops, right?

However, this could surprise a user loading the module and not seeing
any new interface.  Is it because of backward compatibility that you
create one dummy interface by default?

For this reason I also consider a default of one vcan interface to be
created automatically.  But then 1 seems almost as arbitrarily as 4,
since also 1 is not needed for PF_CAN to work.

I currently still prefer no default interfaces, since we would get rid
of some code.

What is the reason you don't like a module parameter to control the
number of default interfaces?  We still have that in our code
currently (but I'm about to remove it).

urs
