From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH][RFC] network splice receive
Date: Tue, 5 Jun 2007 14:20:31 +0200
Message-ID: <20070605122031.GE9909@kernel.dk>
References: <20070605080542.GA9909@kernel.dk> <20070605114545.GC9909@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:12792 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753163AbXFEMWX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 08:22:23 -0400
Received: from nelson.home.kernel.dk (nelson.home.kernel.dk [192.168.0.33])
	by kernel.dk (Postfix) with ESMTP id D83502572B6
	for <netdev@vger.kernel.org>; Tue,  5 Jun 2007 14:22:20 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20070605114545.GC9909@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 05 2007, Jens Axboe wrote:
> On Tue, Jun 05 2007, Jens Axboe wrote:
> > Seems to work reasonably well for me, sometimes I do see small ranges
> > inside the output file that are not correct, but I haven't been able to
> > reproduce today. I think it has to do with page reuse, hence the
> > NET_COPY_SPLICE ifdef that you can enable to just plain copy the data
> > instead of referencing it.
> 
> I managed to reproduce. It's segments of 68-80 bytes beyond corrupt in
> the middle of the out, and there might be 1-3 of such occurences in the
> 30mb file I tested with. The first 16 bytes of the corruption are always
> the same:
> 
> 0000 1800 4ff3 937f e000 6381 7275 0008
> 
> Perhaps that hex pattern rings a bell with someone intimate with the
> networking. The remaining wrong bytes don't seem to have anything in
> common.

Ok, the source mac address is 00:18:F3:4F:7F:93 and the destination is
00:E0:81:63:75:72 which are the middle 12 bytes of the 16.

Hope that helps someone clue me in as to which network part is reusing
the data. Do I need to 'pin' the sk_buff until the pipe data has been
consumed?

-- 
Jens Axboe

