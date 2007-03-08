From: Giridhar Pemmasani <pgiri@yahoo.com>
Subject: Re: [patch 18/19] mv643xx ethernet driver IRQ registration fix
Date: Wed, 7 Mar 2007 16:05:13 -0800 (PST)
Message-ID: <983376.58847.qm@web32410.mail.mud.yahoo.com>
References: <20070306164638.GB22043@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: jeff@garzik.org, netdev@vger.kernel.org, giri@lmc.cs.sunysb.edu,
	pgiri@yahoo.com
To: Dale Farnsworth <dale@farnsworth.org>, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web32410.mail.mud.yahoo.com ([68.142.207.203]:38153 "HELO
	web32410.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S2992787AbXCHAFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 19:05:15 -0500
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

I got a chance to test this patch today. I can confirm that this patch fixes
the issue reported.

Thanks,
Giri


 
____________________________________________________________________________________
The fish are biting. 
Get more visitors on your site using Yahoo! Search Marketing.
http://searchmarketing.yahoo.com/arp/sponsoredsearch_v2.php
