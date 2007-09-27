From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Thu, 27 Sep 2007 09:54:08 -0600
Message-ID: <m1hclgm7dr.fsf@ebiederm.dsl.xmission.com>
References: <20070920184323.3795.0@janus.isnogud.escape.de>
	<20070920184533.3795.5@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:33591 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbXI0Pz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 11:55:26 -0400
In-Reply-To: <20070920184533.3795.5@janus.isnogud.escape.de> (Urs Thuermann's
	message of "Thu, 20 Sep 2007 20:43:28 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann <urs@isnogud.escape.de> writes:

> This patch adds the virtual CAN bus (vcan) network driver.
> The vcan device is just a loopback device for CAN frames, no
> real CAN hardware is involved.

I'm trying to wrap my head around the CAN use of IFF_LOOPBACK.

>  6.2 loopback
>
>  As described in chapter 3.2 the CAN network device driver should
>  support a local loopback functionality. In this case the driver flag
>  IFF_LOOPBACK has to be set to cause the PF_CAN core to not perform the
>  loopback as fallback solution:
>
>    dev->flags = (IFF_NOARP | IFF_LOOPBACK);
>

Currently IFF_LOOPBACK set in dev->flags means we are dealing
with drivers/net/loopback.c. 

In other networking layers loopback functionality (i.e. for broadcast)
is never expected to be provided by the drivers and is instead 
always provided by the networking layer.  Keeping the drivers
simpler.  Further you already have this functionality in the
generic CAN layer for doing loopback without driver support.

So at a first glance the CAN usage of IFF_LOOPBACK looks completely
broken, and likely to confuse other networking layers if they see
a CAN device.  Say if someone attempts to run IP over CAN or
something like that.

Do you think you can remove this incompatible usage of IFF_LOOPBACK
from the can code?

If I have read your documentation properly the only reason you are
doing this is so that the timing of frames to cansniffer more
accurately reflects when the frame hits the wire.  If CAN runs over a
very slow medium I guess I can see where that can be a concern.  But
the usage of IFF_LOOPBACK to do this still feels fairly hackish
to me. 

Eric
