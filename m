From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 5/5] net: phy: Add downshift get/set support in
 Microsemi PHYs driver
Date: Fri, 4 Nov 2016 14:55:00 +0100
Message-ID: <20161104135500.GB3600@lunn.ch>
References: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
 <1478255742-25693-6-git-send-email-allan.nielsen@microsemi.com>
 <20161104122746.GK13959@lunn.ch>
 <20161104134234.GC11277@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        raju.lakkaraju@microsemi.com, cphealy@gmail.com, robh@kernel.org
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36930 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754278AbcKDNzD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 09:55:03 -0400
Content-Disposition: inline
In-Reply-To: <20161104134234.GC11277@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 04, 2016 at 02:42:34PM +0100, Allan W. Nielsen wrote:
> On 04/11/16 13:27, Andrew Lunn wrote:
> > > +     } else if (count) {
> > > +             /* Downshift count is either 2,3,4 or 5 */
> > > +             count = (((count - 2) << DOWNSHIFT_CNTL_POS) | DOWNSHIFT_EN);
> > 
> > Ah, now i see why + 2. But this means it never does what you ask it to
> > do. It would be better to round up < 2 to 2, and leave all the others
> > as is.
> Not sure I understand what you mean...
> 
> If the user configure "count == 1", then you want that to be rounded up to
> "count == 2", because the HW does not support a count of 1???

Yes. The other option would be to return ERANGE when 1 is asked
for. The real question is, which is better for the user? Returning
ERANGE and letting the user make a guessing game to figure out what is
valid, or magically turn 1 into 2. I will let you decide which is
best.

> If the user configure count to 6, 7, 8 etc. would you also like to round it down
> to 5?

No. ERANGE. The user has to expect some upper limit, and ERANGE is a
good indication they have reached it. But having a lowered limit of 2
is less obvious.

   Andrew
