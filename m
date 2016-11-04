From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: Re: [PATCH net-next 5/5] net: phy: Add downshift get/set support in
 Microsemi PHYs driver
Date: Fri, 4 Nov 2016 14:42:34 +0100
Message-ID: <20161104134234.GC11277@microsemi.com>
References: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
 <1478255742-25693-6-git-send-email-allan.nielsen@microsemi.com>
 <20161104122746.GK13959@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: <netdev@vger.kernel.org>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <cphealy@gmail.com>,
        <robh@kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0049.outbound.protection.outlook.com ([104.47.42.49]:53280
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933194AbcKDNml (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 09:42:41 -0400
Content-Disposition: inline
In-Reply-To: <20161104122746.GK13959@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/16 13:27, Andrew Lunn wrote:
> > +     } else if (count) {
> > +             /* Downshift count is either 2,3,4 or 5 */
> > +             count = (((count - 2) << DOWNSHIFT_CNTL_POS) | DOWNSHIFT_EN);
> 
> Ah, now i see why + 2. But this means it never does what you ask it to
> do. It would be better to round up < 2 to 2, and leave all the others
> as is.
Not sure I understand what you mean...

If the user configure "count == 1", then you want that to be rounded up to
"count == 2", because the HW does not support a count of 1???

If the user configure count to 6, 7, 8 etc. would you also like to round it down
to 5?

I'm okay with that but not sure it is want you mean... (and it will eliminate
your comment on ERANGE - because all values will be accepted, they are just
rounded to "closet" supported value).


(The other comments is understood, and we will get them fixed).


/Allan
