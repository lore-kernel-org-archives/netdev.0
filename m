From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix limited slow start bug
Date: Thu, 22 Feb 2007 22:42:36 -0800 (PST)
Message-ID: <20070222.224236.95058339.davem@davemloft.net>
References: <45DDE756.20001@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47023
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752137AbXBWGmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Feb 2007 01:42:38 -0500
In-Reply-To: <45DDE756.20001@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


John, what tree did you diff this against?

I can tell you didn't create this patch against anything
actually in any of my trees, because:

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 7fd2910..a0c894f 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -303,9 +303,9 @@ void tcp_slow_start(struct tcp_sock *tp)
 	
 	tp->snd_cwnd_cnt += cnt;

See that line right before the snd_cwnd_cnt increment?

There is a tab there in your patch on that empty line.

Yoshifuji eliminated all extraneous trailing whitespaces,
and spaces that should be tabs, across the entire networking,
several weeks ago.  Including the tab on that empty line in
your patch.

This means that you applied the YeaH and your own patch to
another source tree, perhaps 2.6.20 or similar, and then
generated your fix against that.

Please don't do things like that.  Instead please produce patches
against the tree they will end up being applied to so that they will
apply cleanly for me.

I can't believe how much time I spend getting people to produce
correct patches :-/

Anyways, I applied this by hand, but next time I definitely
am not going to.
