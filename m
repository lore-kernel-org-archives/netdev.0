From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/4] dsa: mv88e6xxx: Delete ppu timer when removing module
Date: Mon, 22 Aug 2016 17:07:45 +0200
Message-ID: <20160822150745.GC16229@lunn.ch>
References: <1471874464-16142-1-git-send-email-andrew@lunn.ch>
 <1471874464-16142-4-git-send-email-andrew@lunn.ch>
 <87zio47t7s.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jamie Lentin <jm@lentin.co.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40668 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751774AbcHVPHv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 11:07:51 -0400
Content-Disposition: inline
In-Reply-To: <87zio47t7s.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 10:51:03AM -0400, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > The PPU method of accessing PHYs makes use of a timer. Make sure this
> > timer is deleted before unloading the driver.
> >
> > Reported-by: Jamie Lentin <jm@lentin.co.uk>
> > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> 
> I'm wondering if the PPU shouldn't be disabled before unloading the
> module...

Humm, i did not thing about that.

Actually, we have a general issue here. On unload, we leave the switch
'running'. The SF2 driver disables all the ports. The b53 seems to
leave the switch running.

We should define a general policy about this, and implement it in all
drivers. As such, your comment is valid, but a different patch set.

	Andrew
