From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH][RFC] network splice receive
Date: Tue, 5 Jun 2007 13:45:46 +0200
Message-ID: <20070605114545.GC9909@kernel.dk>
References: <20070605080542.GA9909@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:22264 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752786AbXFELrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 07:47:37 -0400
Received: from nelson.home.kernel.dk (nelson.home.kernel.dk [192.168.0.33])
	by kernel.dk (Postfix) with ESMTP id 0E04A2571F0
	for <netdev@vger.kernel.org>; Tue,  5 Jun 2007 13:47:35 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20070605080542.GA9909@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 05 2007, Jens Axboe wrote:
> Seems to work reasonably well for me, sometimes I do see small ranges
> inside the output file that are not correct, but I haven't been able to
> reproduce today. I think it has to do with page reuse, hence the
> NET_COPY_SPLICE ifdef that you can enable to just plain copy the data
> instead of referencing it.

I managed to reproduce. It's segments of 68-80 bytes beyond corrupt in
the middle of the out, and there might be 1-3 of such occurences in the
30mb file I tested with. The first 16 bytes of the corruption are always
the same:

0000 1800 4ff3 937f e000 6381 7275 0008

Perhaps that hex pattern rings a bell with someone intimate with the
networking. The remaining wrong bytes don't seem to have anything in
common.

Slab poisoning doesn't change the pattern, so it's not use-after-free.


-- 
Jens Axboe

