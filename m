From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] dsa: mv88e6xxx: Timeout based on iterations
Date: Thu, 18 Aug 2016 20:39:46 +0200
Message-ID: <20160818183946.GD13458@lunn.ch>
References: <1471469225-368-1-git-send-email-andrew@lunn.ch>
 <87oa4rat8o.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38710 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752314AbcHSCxu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 22:53:50 -0400
Content-Disposition: inline
In-Reply-To: <87oa4rat8o.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >  static int mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int addr, int reg,
> >  			  u16 mask)
> >  {
> > -	unsigned long timeout = jiffies + HZ / 10;
> > +	int i;
> >  
> > -	while (time_before(jiffies, timeout)) {
> > +	for (i = 0; i < 16; i++) {
> >  		u16 val;
> >  		int err;
> >  
> 
> Since we remove the elapsed time here, can we use mv88e6xxx_wait in
> mv88e6xxx_update? It'd be good to have a consistent wait routine
> everywhere.

Hi Vivien

Yes, it looks like that should work. I will add a second patch to do
this.

	Andrew
