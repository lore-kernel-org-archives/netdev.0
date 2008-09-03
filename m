From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Tue, 02 Sep 2008 23:10:35 -0700 (PDT)
Message-ID: <20080902.231035.163736332.davem@davemloft.net>
References: <E1KakUR-0001xp-00@gondolin.me.apana.org.au>
	<48BE1B95.8000508@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37383
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753027AbYICGKm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 02:10:42 -0400
In-Reply-To: <48BE1B95.8000508@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Wed, 03 Sep 2008 08:07:33 +0300

> Also alternatively the xfrm_state_all could be protected by a
> different lock than xfrm_state_lock.

Before your changes the state destroy was protected by no central
locks at all.  There was no need.

Since the reference goes to zero, there are no external references
to this object.

But this is exactly what you added, an external references that is
not reference counted.

This is yet another reason all of Herbert's objections to your
location for ->all list add and removal are sound.

So we now have to take a centralized lock twice when getting rid of an
XFRM state object.  Which is potentially a scalability performance
regression.
