From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC] net: mvneta: add ethtool statistics
Date: Thu, 8 Oct 2015 17:32:57 +0200
Message-ID: <20151008153257.GT17952@lunn.ch>
References: <20151006165208.GE3557@lunn.ch>
 <E1ZjZ2q-00087d-Im@rmk-PC.arm.linux.org.uk>
 <20151007230333.GL17952@lunn.ch>
 <20151008085141.GA32532@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41473 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934131AbbJHPdC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 11:33:02 -0400
Content-Disposition: inline
In-Reply-To: <20151008085141.GA32532@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > This would suggest the driver is not clearing the statistics when it
> > loads. Should it?
> 
> That's an interesting question, one which I have no answer for.

So i took a look at the other Marvell drivers. mv643xx_eth.c, skge and
sky2.c all have code to clear the statistics. So for consistency, i
think nvneta should as well.

But it gets stranger. mvneta has:

static void mvneta_mib_counters_clear(struct mvneta_port *pp)
{
        int i;
        u32 dummy;

        /* Perform dummy reads from MIB counters */
        for (i = 0; i < MVNETA_MIB_LATE_COLLISION; i += 4)
                dummy = mvreg_read(pp, (MVNETA_MIB_COUNTERS_BASE + i));
}

Looks like somebody did not finish this?

      Andrew
