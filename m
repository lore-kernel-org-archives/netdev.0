From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tg3: ethtool phys_id default (rev2)
Date: Mon, 25 Feb 2008 07:58:14 -0800
Message-ID: <20080225075814.577b3eb6@extreme>
References: <20080222102429.7e48f1f1@extreme>
	<1203707802.13495.169.camel@dell>
	<20080223.195221.177613282.davem@davemloft.net>
	<1203831726.8232.115.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, mchan@broadcom.com,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: "Eliezer Tamir" <eliezert@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:56938 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753426AbYBYP6W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 10:58:22 -0500
In-Reply-To: <1203831726.8232.115.camel@lb-tlvb-eliezer.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 24 Feb 2008 07:42:06 +0200
"Eliezer Tamir" <eliezert@broadcom.com> wrote:

> 
> On Sat, 2008-02-23 at 19:52 -0800, David Miller wrote:
> > From: "Michael Chan" <mchan@broadcom.com>
> > Date: Fri, 22 Feb 2008 11:16:42 -0800
> > 
> > > On Fri, 2008-02-22 at 10:24 -0800, Stephen Hemminger wrote:
> > > > When asked to blink LEDs the tg3 driver behaves when using:
> > > > 	ethtool -p ethX
> > > > The default value for data is zero, and other drivers interpret this
> > > > as blink forever (or at least a really long time).  The tg3 driver
> > > > interprets this as blink once.  All drivers should have the same
> > > > behaviour.
> ...
> > > We should do this across the board for bnx2, bnx2x, and niu as well.
> > 
> > Agreed.
> 
> Doesn't this mean that ethtool -p will hold the RTNL lock forever?
> Is this a good idea?
> 
> For example on the Red Hat machine I have here if you do:
> 
> ethtool -p eth2 100000 &
> reboot
> 
> Various things the shutdown scripts try to do will fail because of the
> held RTNL lock. in the end the script dies and the machine does not
> reboot.

1. ethtool -p is only used by root to identify interfaces, so in practice
   this is not a real problem.

2. ethtool -p is interruptible, and the reboot process sends a SIGTERM to
   all processes.
