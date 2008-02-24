From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: [PATCH] tg3: ethtool phys_id default (rev2)
Date: Sun, 24 Feb 2008 07:42:06 +0200
Message-ID: <1203831726.8232.115.camel@lb-tlvb-eliezer.il.broadcom.com>
References: <20080222102429.7e48f1f1@extreme>
 <1203707802.13495.169.camel@dell>
 <20080223.195221.177613282.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, shemminger@vyatta.com, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2613 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753559AbYBXFmW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Feb 2008 00:42:22 -0500
In-Reply-To: <20080223.195221.177613282.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 2008-02-23 at 19:52 -0800, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Fri, 22 Feb 2008 11:16:42 -0800
> 
> > On Fri, 2008-02-22 at 10:24 -0800, Stephen Hemminger wrote:
> > > When asked to blink LEDs the tg3 driver behaves when using:
> > > 	ethtool -p ethX
> > > The default value for data is zero, and other drivers interpret this
> > > as blink forever (or at least a really long time).  The tg3 driver
> > > interprets this as blink once.  All drivers should have the same
> > > behaviour.
...
> > We should do this across the board for bnx2, bnx2x, and niu as well.
> 
> Agreed.

Doesn't this mean that ethtool -p will hold the RTNL lock forever?
Is this a good idea?

For example on the Red Hat machine I have here if you do:

ethtool -p eth2 100000 &
reboot

Various things the shutdown scripts try to do will fail because of the
held RTNL lock. in the end the script dies and the machine does not
reboot.

Eliezer





