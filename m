From: David Miller <davem@davemloft.net>
Subject: Re: SACK scoreboard
Date: Mon, 07 Jan 2008 23:36:17 -0800 (PST)
Message-ID: <20080107.233617.203640686.davem@davemloft.net>
References: <Pine.LNX.4.64.0712081523470.17809@kivilampi-30.cs.helsinki.fi>
	<20071211.043239.224938181.davem@davemloft.net>
	<Pine.LNX.4.64.0712111547300.18529@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lachlan.andrew@gmail.com, netdev@vger.kernel.org,
	quetchen@caltech.edu
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43069
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751526AbYAHHgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 02:36:18 -0500
In-Reply-To: <Pine.LNX.4.64.0712111547300.18529@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ilpo, just trying to keep an old conversation from dying off.

Did you happen to read a recent blog posting of mine?

	http://vger.kernel.org/~davem/cgi-bin/blog.cgi/2007/12/31#tcp_overhead

I've been thinking more and more and I think we might be able
to get away with enforcing that SACKs are always increasing in
coverage.

I doubt there are any real systems out there that drop out of order
packets that are properly formed and are in window, even though the
SACK specification (foolishly, in my opinion) allows this.

If we could free packets as SACK blocks cover them, all the problems
go away.

For one thing, this will allow the retransmit queue liberation during
loss recovery to be spread out over the event, instead of batched up
like crazy to the point where the cumulative ACK finally moves and
releases an entire window's worth of data.

Next, it would simplify all of this scanning code trying to figure out
which holes to fill during recovery.

And for SACK scoreboard marking, the RB trie would become very nearly
unecessary as far as I can tell.

I would not even entertain this kind of crazy idea unless I thought
the fundamental complexity simplification payback was enormous.  And
in this case I think it is.

What we could do is put some experimental hack in there for developers
to start playing with, which would enforce that SACKs always increase
in coverage.  If violated the connection reset and a verbose log
message is logged so we can analyze any cases that occur.

Sounds crazy, but maybe has potential.  What do you think?
