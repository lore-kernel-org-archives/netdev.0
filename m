From: Michael Welling <mwelling@ieee.org>
Subject: Re: [PATCH] net: phy: Handle postive return codes in phy_connect
Date: Sat, 5 Sep 2015 15:26:29 -0500
Message-ID: <20150905202629.GB6250@deathstar>
References: <1441476089-22108-1-git-send-email-mwelling@ieee.org>
 <20150905191840.GC6040@lunn.ch>
 <20150905194400.GA1687@deathstar>
 <20150905194755.GD6040@lunn.ch>
 <55EB4C87.4030309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34968 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752591AbbIEU0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 16:26:37 -0400
Content-Disposition: inline
In-Reply-To: <55EB4C87.4030309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 05, 2015 at 01:11:51PM -0700, Florian Fainelli wrote:
> Le 09/05/15 12:47, Andrew Lunn a =E9crit :
> > On Sat, Sep 05, 2015 at 02:44:01PM -0500, Michael Welling wrote:
> >> On Sat, Sep 05, 2015 at 09:18:40PM +0200, Andrew Lunn wrote:
> >>> On Sat, Sep 05, 2015 at 01:01:29PM -0500, Michael Welling wrote:
> >>>> The function phy_connect_direct can possibly return a positive
> >>>> return code. Using ERR_PTR with a positive value can lead to
> >>>> deferencing of an invalid pointer.
> >>>
> >>> Is this the correct fix? Would it not be better to find where the
> >>> positive return code is from and fix that?
> >>
> >> I guess I can trace it back to find out where the positive return =
code
> >> is originating.
> >>
> >> Is phy_connect_direct always supposed to return valid -errno?
> >=20
> > I would look at this from a different angle. A positive ERRNO is
> > probably a bug of some sort. So rather than papering over the crack=
s,
> > go find what the real issue is.
>=20
> Agreed, you could place a WARN_ON(rc > 0) and get the offending call
> trace leading to that problem. I suspect that one of the PHY drivers
> might be returning a positive value as part of a phy_read() call and
> that does not get properly filtered out.
>

Thanks for the feedback.

Does it hurt to always have a warning on positive return codes before
using ERR_PTR?

> >=20
> > It might not be an ERRNO. E.g. https://lkml.org/lkml/2015/9/3/534
> > fixed a bug where a positive value is returned which is not an
> > indication of an error.
> >=20
> > 	   Andrew
> >=20
> --=20
> Florian
