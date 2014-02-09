From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH][Trivial] tcp: correct code comment stating 3 min timeout
 for FIN_WAIT2, we only do 1 min
Date: Sun, 9 Feb 2014 23:30:32 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1402092328270.8418@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As far as I can tell we have used a default of 60 seconds for
FIN_WAIT2 timeout for ages (since 2.x times??).

In any case, the timeout these days is 60 seconds, so the 3 min
comment is wrong (and cost me a few minutes of my life when I was
debugging a FIN_WAIT2 related problem in a userspace application and
checked the kernel source for details).

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 net/ipv4/tcp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4475b3b..9f3a2db 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2229,7 +2229,7 @@ adjudge_to_death:
 	/*	This is a (useful) BSD violating of the RFC. There is a
 	 *	problem with TCP as specified in that the other end could
 	 *	keep a socket open forever with no application left this end.
-	 *	We use a 3 minute timeout (about the same as BSD) then kill
+	 *	We use a 1 minute timeout (about the same as BSD) then kill
 	 *	our end. If they send after that then tough - BUT: long enough
 	 *	that we won't make the old 4*rto = almost no time - whoops
 	 *	reset mistake.
-- 
1.7.1


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
