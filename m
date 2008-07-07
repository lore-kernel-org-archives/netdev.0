From: Mattias Nissler <mattias.nissler@gmx.de>
Subject: Re: [PATCH] rc80211_pid: Fix fast_start parameter handling
Date: Mon, 07 Jul 2008 22:39:05 +0200
Message-ID: <1215463145.4416.11.camel@localhost>
References: <19f34abd0807070427w5398c617uae0a4e8e40fd8f0e@mail.gmail.com>
	 <1215462228.4416.3.camel@localhost>
	 <19f34abd0807071331s52dc994ao6ac70e787d88227d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stefano Brivio <stefano.brivio@polimi.it>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Pekka Enberg <penberg@cs.helsinki.fi>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:42382 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756621AbYGGUjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 16:39:11 -0400
In-Reply-To: <19f34abd0807071331s52dc994ao6ac70e787d88227d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-07-07 at 22:31 +0200, Vegard Nossum wrote:
> Hi,
> 
> On Mon, Jul 7, 2008 at 10:23 PM, Mattias Nissler <mattias.nissler@gmx.de> wrote:
> > This removes the fast_start parameter from the rc_pid parameters information
> > and instead uses the parameter macro when initializing the rc_pid state. Since the
> > parameter is only used on initialization, there is no point of making exporting
> > it via debugfs. This also fixes uninitialized memory references to the
> > fast_start and norm_offset parameters.
> >
> > Signed-off-by: Mattias Nissler <mattias.nissler@gmx.de>
> > ---
> >
> > This should fix the problem. I think this should go into mainline ASAP.
> 
> Was this code actually causing some problem/regression? If so, can we
> please have a reference to bugzilla/prior conversations in the patch
> description?

I think the problem probably didn't cause any major problem at all. At
most, the rate scaling didn't work properly. Maybe the algorithm would
even recover from the incorrect initialization (not too sure about this
one, better ask Stefano about the rate sorting implications). And no, I
have never seen any problem reports that relate to this bug. I wouldn't
call it a regression either, since this is exactly the code that went
mainline with the first version of rc80211_pid.

> 
> Was the reason for the problem known before I posted the "use of
> uninitialized memory" e-mail earlier today? If no, can you please
> sneak in a little reference to kmemcheck there in the patch
> description? The acknowledgement is sorely needed :-)

It was unknown before. Just a sec, I'll post new version of the patch
that mentions kmemcheck ;-)

Mattias

