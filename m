From: Willy Tarreau <w@1wt.eu>
Subject: planned driver updates for 2.4.35
Date: Mon, 29 Jan 2007 22:01:13 +0100
Message-ID: <20070129210113.GA17816@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Stephen Hemminger <shemminger@osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2195 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751846AbXA2VB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 16:01:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

As stated with the 2.4.34 announcement, I planned to perform a few
updates in two network drivers for 2.4.35 :

  - e1000: the cards equipped with the not-so old 82546EB chips
    have completely disappeared from the earth surface, and
    people replacing hardware are experiencing trouble with the
    new chip (82546GB) which is not supported by the old driver.
    I know that Red Hat merged support for this chip in RHEL3
    recently too (U8) by upgrading from v6 to v7.

    Jesse Brandeburg from Intel offered to update the driver to
    the more recent branch (7.3), which will make further
    maintenance easier for him. I personnally use 7.3 on my own
    kernels, so I just know that it works well for the NICs I'm
    used to find on servers, but for the rest, I'll have to rely
    on Intel people's support.

  - sk98lin: when Stephen decided to rewrite that driver from scratch
    because the one from Marvell's site has too many bugs, I thought
    he was exagerating, till the day I noticed NFS servers taking a
    lot of time to respond and DNS servers timing out because of UDP
    packets suddenly not leaving the host anymore. I recently
    encountered a worst case at a customer's with losses, duplicates
    and truncated packets. It's clear that the driver is too buggy.
    Each time I replaced the official driver with Stephen's backport
    and it definitely fixed the problems. I proposed Stephen to merge
    his work into 2.4, and he agreed, offering to update it once it
    gets in, which I'm fine with.

    This means I would start with skge-1.4 and sky2-0.5 which I could
    not get to fault on various intensive tests nor on the one which
    trigger sk98lin's bugs. Since those drivers support cards that are
    currently only supported by the out-of-tree driver from Marvell's
    site, no compatibility is lost and users can still use their old
    driver if they prefer it (as I did till I got those bugs).

Aside that, I rejected a user's request for an update of the tg3
driver which does not support one recent chip in a notebook. I think
that a notebook is not a big enough argument to touch this driver which
works quite well IMHO. A notebook is clearly where he should use 2.6 by
default, or take the time to download and install the out-of-tree code
from broadcom's site if he absolutely wants 2.4. Maybe I'm wrong, but I
have not tested the unofficial tg3 enough to have an opinion, and I don't
want to break things that work just for this.

I'd like to get your opinion on those updates before I open 2.4.35. I
think that integrating them early is the best way to get more testing,
since people often try the first and the latest versions only.

Best regards,
Willy

