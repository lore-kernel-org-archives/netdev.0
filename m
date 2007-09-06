From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Thu, 06 Sep 2007 13:39:49 -0700 (PDT)
Message-ID: <20070906.133949.112618148.davem@davemloft.net>
References: <46D5FBF3.5050700@hp.com>
	<20070829.161528.38309258.davem@davemloft.net>
	<Pine.LNX.4.64.0709051142260.30179@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rick.jones2@hp.com, ian.mcdonald@jandi.co.nz,
	netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:42331
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757709AbXIFUkD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2007 16:40:03 -0400
In-Reply-To: <Pine.LNX.4.64.0709051142260.30179@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 5 Sep 2007 22:04:11 +0300 (EEST)

> Main obstacle to FRTO use is its deployment as it has to be on the
> sender side where as wireless link is often the receiver's access
> link but if one can tune tcp_min_rto (or equal) on the sender side,
> one could enable FRTO at will as well.

Correct.

I've currently succumbed to the realization that no matter what we
tell these folks about FRTO they aren't interested in testing it as a
usable solution mostly because they already invested to time to find
out that min_rto gives them pretty much what they want.

I'd prefer they used an FRTO based solution but this is reality :)

> Uninteresting enough, even IETF seems to=20
> interested in advancing FRTO from experimental [1].

That's great :)

> A funny sidenote about the experiment, we found out what Linux
> cannot do (from userspace only): it seems to be unable to receive
> the same packet it has sent out to itself as we forced the packet
> out from eth0 by binding sending dev to eth0 and received from ppp0
> =3D> the packet gots always discard as martian and there seems to be
> no knob to that, so had to hack it :-).

Yes, and this is loosely related to the "send to self" patches
that come up from time to time because Linux naturally wants
to just loopback in software any packet you try to direct out
a real interface that matches a local host address.
