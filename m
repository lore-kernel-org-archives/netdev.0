From: Giridhar Pemmasani <pgiri@yahoo.com>
Subject: Re: [patch 18/19] mv643xx ethernet driver IRQ registration fix
Date: Tue, 6 Mar 2007 09:35:55 -0800 (PST)
Message-ID: <934439.58670.qm@web32409.mail.mud.yahoo.com>
References: <20070306164638.GB22043@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: jeff@garzik.org, netdev@vger.kernel.org, giri@lmc.cs.sunysb.edu,
	pgiri@yahoo.com
To: Dale Farnsworth <dale@farnsworth.org>, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web32409.mail.mud.yahoo.com ([68.142.207.202]:27690 "HELO
	web32409.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965380AbXCFRmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 12:42:36 -0500
In-Reply-To: <20070306164638.GB22043@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Dale Farnsworth <dale@farnsworth.org> wrote:

> On Tue, Mar 06, 2007 at 02:42:02AM -0800, akpm@linux-foundation.org wrote:
> > From: Giridhar Pemmasani <giri@lmc.cs.sunysb.edu>
> > 
> > During initialization, mv643xx driver registers IRQ before setting up
> tx/rx
> > rings.  This causes kernel oops because mv643xx_poll, which gets called
> > right after registering IRQ, calls netif_rx_complete, which accesses the
> rx
> > ring (I don't have the oops message anymore; I just remember this
> sequence
> > of calls).  Attached (tested) patch first initializes the rx/tx rings and
> > then registers the IRQ.
> 
> I believe a better fix is to disable any pending interrupt sources
> before calling request_irq().  I sent the patch below to Giri for
> confirmation, but haven't heard back.  I should've copied Andrew.
> 
> Giri, have you had a chance to test this alternative patch?

I will get my hands on the box this Friday. As soon as I can, I will test and
give feedback.

FWIW, I had a patch earlier that was similar (not same) as you suggest. That
patch was based on the changes from 2.6.15 to 2.6.16 when it broke. In
2.6.15, interrupts as well as rx/tx are disabled until rx/tx rings are setup.
Anyway, I will test this and let you know.

Giri


 
____________________________________________________________________________________
Be a PS3 game guru.
Get your game face on with the latest PS3 news and previews at Yahoo! Games.
http://videogames.yahoo.com/platform?platform=120121
