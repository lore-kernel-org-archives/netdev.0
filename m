From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v1 net-next 1/5] net: dsa: mv88e6xxx: Reserved Management
 frames to CPU
Date: Sun, 4 Dec 2016 21:22:34 +0100
Message-ID: <20161204202234.GA20743@lunn.ch>
References: <1480736720-12608-1-git-send-email-andrew@lunn.ch>
 <1480736720-12608-2-git-send-email-andrew@lunn.ch>
 <87y3zvcvhm.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39785 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750979AbcLDUWj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Dec 2016 15:22:39 -0500
Content-Disposition: inline
In-Reply-To: <87y3zvcvhm.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +int mv88e6095_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip)
> > +{
> > +	int err;
> > +
> > +	/* Consider the frames with reserved multicast destination
> > +	 * addresses matching 01:80:c2:00:00:2x as MGMT.
> > +	 */
> > +	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_2X)) {
> 
> Please don't just move the old code. You shouldn't need flags anymore.

Hi Vivien

My aim is to get the 6390 supported. Refactoring is secondary. If it
helps implementing the 6390 code, i will refactor stuff. If it does
not help, i will leave it alone. It does not help here, so i left it
alone. Please feel free to submit a follow up patch refactoring this
further.

> The mv88e6xxx_ops actually implements the *features*. They can be
> prefixed for clarity (e.g. .ppu_*, port_*, .atu_*, etc.). They don't
> describe the register layout.
> 
> But we can discuss two ways of seeing this structure implementation:

or

3) We have a prefix for us humans to help us find the code. Now we
have ops, i cannot simply do M-. and emacs will take me to the
implementation. I have to search for it a bit. Having the hint g1_
tells me to go look in global1.c. Having the hint g2_ tells me to go
look in global2.c. Having the port_ tells me to go look in port.c.
Having no prefix tells me the code is scattered around and grep is my
friend.

The prefix is just a hint where the function is in the source
code. Nothing more.

      Andrew
