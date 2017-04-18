From: Michael Richardson <mcr@sandelman.ca>
Subject: Re: bluetooth 6lowpan interfaces are not virtual anymore
Date: Tue, 18 Apr 2017 12:59:43 -0400
Message-ID: <28530.1492534783@obiwan.sandelman.ca>
References: <2d178eb8-3fbc-3385-6e0c-fa9941713959@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Cc: Network Development <netdev@vger.kernel.org>,
        Jukka Rissanen <jukka.rissanen@linux.intel.com>,
        Luiz Augusto von Dentz <luiz.dentz@gmail.com>,
        "linux-wpan\@vger.kernel.org" <linux-wpan@vger.kernel.org>,
        Linux Bluetooth <linux-bluetooth@vger.kernel.org>
To: Alexander Aring <aar@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tuna.sandelman.ca ([209.87.249.19]:45313 "EHLO
        tuna.sandelman.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757328AbdDRRHf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 13:07:35 -0400
In-Reply-To: <2d178eb8-3fbc-3385-6e0c-fa9941713959@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Type: text/plain


Alexander Aring <aar@pengutronix.de> wrote:
    > What does the 6LoWPAN interface?

    > It will do a protocol change (an adaptation, because 6LoWPAN should
    > provide the same functionality as IPv6) from IPv6 to 6LoWPAN (tx) and
    > vice versa for (rx). In my opinion this should be handled as a virtual
    > interface and not as an interface with a queue.

I wonder if modeling all the 6lowpan work as a virtual interface is even
the right abstraction anymore.  I think that it was certainly a good model at
the time the interface was created, given no other clear thing to do.

We don't model IPv6 ND (or IPv4 ARP) or fragmentation in general as a
virtual interface on top of a raw interface.

Really, it's a set of operations that happens on a packet.
802.15.4 is notable for it's current lack of an ethertype (IEEE is fixing
that though), so you can't actually run different protocols on the
same PANID.
BT does have a variety of different protocols, and IPv6 is only one.

In a classic SVR4 STREAMS works, it would have been just another module.
(No, I'm not a fan of *STREAMS* or of SVR4 in general,  although I liked
some of the ideas).

At this time, things like PANID and channel are set on the wpanX interface.
If they were set on the 6lowpan interface, such that one could (in theory,
assuming the hardware could do it, which some can, and some can not) then
one could have multiple 6lowpan interfaces on top of the same wpanX.
Or one could run some non-IP protocol like pre-IP Zigbee on one PANID
while one runs 6lowpan on another.  THEN, a virtual interface would make
sense for the same reason VLAN interfaces make sense.

--=-=-=--
