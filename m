From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 08:41:37 -0700
Message-ID: <20071002154137.GD17418@bitmover.com>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: lm@bitmover.com, Herbert Xu <herbert@gondor.apana.org.au>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:43325 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752754AbXJBPli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 11:41:38 -0400
Content-Disposition: inline
In-Reply-To: <20071002150935.GC17418@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Interesting data point.  My test case is like this:

server
	bind
	listen
	while (newsock = accept...)
		transfer()

client
	connect
	transfer

If the server side is the source of the data, i.e, it's transfer is a 
write loop, then I get the bad behaviour.  If I switch them so the data
flows in the other direction, then it works, I go from about 14K pkt/sec
to 43K pkt/sec.

Can anyone else reproduce this?  I can extract the test case from lmbench
so it is standalone but I suspect that any test case will do it.  I'll
try with the one that John sent.  Yup, s/read/write/ and s/write/read/
in his two files at the appropriate places and I get exactly the same
behaviour.

So is this a bug or intentional?
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
