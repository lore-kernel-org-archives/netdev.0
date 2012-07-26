From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Thu, 26 Jul 2012 15:53:27 -0700 (PDT)
Message-ID: <20120726.155327.947597248143903676.davem@davemloft.net>
References: <CAKgT0UfZmK=gSSn+1Z8=KpW9ckVAJJgQg1+5NdO9SKfWv8GiCg@mail.gmail.com>
	<20120726.140601.1137230112117936793.davem@davemloft.net>
	<CAKgT0Ue4mRUpEmKA7SNpTv8D7BKcxYQ65PGoOUkxB27sLuT1Rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56996 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013Ab2GZWx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 18:53:28 -0400
In-Reply-To: <CAKgT0Ue4mRUpEmKA7SNpTv8D7BKcxYQ65PGoOUkxB27sLuT1Rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 26 Jul 2012 15:03:39 -0700

> Here is the latest perf results with all of these patches in place.
> As you predicted your patch essentially cut the lookup overhead in
> half:

Ok good.

That patch is hard to make legitimate, I'd have to do a bit or work
before we could realize that change.

We can only combine the LOCAL and MAIN tables like that so long as
there are no overlaps in the routes covered by the two tables.  We'd
also have to be sure to report the routes properly in dumps too.

I really wish we had never segregated these two tables, it's
completely pointless and hurts performance.  But now we have to
accomodate this legacy.
