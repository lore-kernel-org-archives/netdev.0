From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 0/9]: TCP: The Road to Super TSO
Date: Mon, 06 Jun 2005 21:08:46 -0700 (PDT)
Message-ID: <20050606.210846.07641049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jheffner@psc.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Some folks, notable the S2IO guys, get performance degradation
from the Super TSO v2 patch (they get it from the first version
as well).  It's a real pain to spot what causes such things
in such a huge patch... so I started splitting things up in
a very fine grained manner so we can catch regressions more
precisely.

There are several bugs spotted by this first set of 9 patches,
and I'd really appreciate good high-quality testing reports.
Please do not mail such reports privately to me, as some have
done, always include netdev@oss.sgi.com, thanks a lot.

Herbert, I'm CC:'ing you because one of the bugs fixed here
has to do with the TSO header COW'ing stuff you did.  You
missed one case where a skb_header_release() call was needed,
namely tcp_fragment() where it does it's __skb_append().

John, I'm CC:'ing you because there are several cwnd handling
related cures in here.  I did _not_ fix the TSO cwnd growth
bug yet in these patches, but it is at the very top of my
TODO list for my next batch of work on this stuff.  The most
notable fix here is the bogus extra cwnd validation done by
__tcp_push_pending_frames().  That validation should only
occur if we _do_ send some packets, and tcp_write_xmit() takes
care of that just fine.  The other one is that the 'nonagle'
argument to __tcp_push_pending_frames() is clobbered by it's
tcp_skb_is_last() logic, causing TCP_NAGLE_PUSH to be used for
all packets processed by tcp_write_xmit(), whoops...

Please help me review this stuff, thanks.

The patches will show up as followups to this email.
