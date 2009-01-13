From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Tue, 13 Jan 2009 15:08:51 -0800 (PST)
Message-ID: <20090113.150851.161423735.davem@davemloft.net>
References: <49667534.5060501@zeus.com>
	<20090108.135515.85489589.davem@davemloft.net>
	<20090108222039.GC24243@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@zeus.com, jarkao2@gmail.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42382
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751661AbZAMXIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 18:08:50 -0500
In-Reply-To: <20090108222039.GC24243@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Thu, 8 Jan 2009 23:20:39 +0100

> On Thu, Jan 08, 2009 at 01:55:15PM -0800, David Miller wrote:
> > I'm not applying this until someone explains to me why
> > we should remove this test from the splice receive but
> > keep it in the tcp_recvmsg() code where it has been
> > essentially forever.
> 
> In my opinion, the code structure is different between both functions. In
> tcp_recvmsg(), we test for it if (copied > 0), where copied is the sum of
> all data which have been processed since the entry in the function. If we
> removed the test here, we could not break out of the loop once we have
> copied something. In tcp_splice_read(), the test is still present in the
> (!ret) code path, where ret is the last number of bytes processed, so the
> test is still performed regardless of what has been previously transferred.
> 
> So in summary, in tcp_splice_read without this test, we get back to the
> top of the loop, and if __tcp_splice_read() returns 0, then we break out
> of the loop.

Ok I see what you're saying, the !timeo check is only
necessary when the receive queue has been exhausted.
