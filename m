From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] tg3: Bugfixes and 5719 support
Date: Mon, 07 Jun 2010 00:28:05 -0700 (PDT)
Message-ID: <20100607.002805.232920368.davem@davemloft.net>
References: <1275794679-11085-1-git-send-email-mcarlson@broadcom.com>
	<20100606.180029.42789560.davem@davemloft.net>
	<20100607035934.GB11599@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41927
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756308Ab0FGH1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 03:27:55 -0400
In-Reply-To: <20100607035934.GB11599@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Sun, 6 Jun 2010 20:59:34 -0700

> On Sun, Jun 06, 2010 at 06:00:29PM -0700, David Miller wrote:
> The programming manual says this bit prevents a tx state machine lockup
> due to tx mbuf corruption.  The conditions under which the tx mbufs get
> corrupted is complicated, but the net effect of this bit is that the
> RDMA engine acts a little more conservatively.

That last phrase is a good description and could have been used to
better name the register bit macro in question.  You're basically
confirming that you named the register bit too tersely.

> The problem is that register definitions can change from asic rev to
> asic rev.

Frankly, this kind of justification really ticks me off.

How the heck does that make a difference?  Describe which chip revs
the register bit is valid for in a comment for crying out loud.

Document your hardware properly, not selectively or where you see
it fit to do so.

It's bad enough that you guys don't publish your hardware specs.
As a consequence as much knowledge as possible must go into the
driver sources.  Any piece of information you take away is bad.

There are tons of chip register bits in this driver already which are
only valid on certain hardware revs.  In fact, there are many.  Yet
they are all still there in tg3.h whether they are used by the driver
or not.  In fact, if I recall correctly, the DMA burst size controls
are pretty much different on every single rev of the chip.

Documenting where for which chips a register bit is valid is
pervasively done elsewhere, and is nothing new.  Your driver and your
hardware is not special.

