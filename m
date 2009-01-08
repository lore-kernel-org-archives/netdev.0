From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Thu, 08 Jan 2009 13:55:15 -0800 (PST)
Message-ID: <20090108.135515.85489589.davem@davemloft.net>
References: <20090108173028.GA22531@1wt.eu>
	<49667534.5060501@zeus.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, jarkao2@gmail.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: ben@zeus.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54409
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752100AbZAHVzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 16:55:13 -0500
In-Reply-To: <49667534.5060501@zeus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Mansell <ben@zeus.com>
Date: Thu, 08 Jan 2009 21:50:44 +0000

> > From fafe76713523c8e9767805cfdc7b73323d7bf180 Mon Sep 17 00:00:00 2001
> > From: Willy Tarreau <w@1wt.eu>
> > Date: Thu, 8 Jan 2009 17:10:13 +0100
> > Subject: [PATCH] tcp: splice as many packets as possible at once
> > Currently, in non-blocking mode, tcp_splice_read() returns after
> > splicing one segment regardless of the len argument. This results
> > in low performance and very high overhead due to syscall rate when
> > splicing from interfaces which do not support LRO.
> > The fix simply consists in not breaking out of the loop after the
> > first read. That way, we can read up to the size requested by the
> > caller and still return when there is no data left.
> > Performance has significantly improved with this fix, with the
> > number of calls to splice() divided by about 20, and CPU usage
> > dropped from 100% to 75%.
> > 
> 
> I get similar results with my testing here. Benchmarking an application with this patch shows that more than one packet is being splice()d in at once, as a result I see a doubling in throughput.
> 
> Tested-by: Ben Mansell <ben@zeus.com>

I'm not applying this until someone explains to me why
we should remove this test from the splice receive but
keep it in the tcp_recvmsg() code where it has been
essentially forever.
