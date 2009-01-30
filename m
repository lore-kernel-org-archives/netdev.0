From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Fri, 30 Jan 2009 13:42:27 -0800 (PST)
Message-ID: <20090130.134227.123379239.davem@davemloft.net>
References: <20090126212130.GA4338@ioremap.net>
	<20090126.221056.174077798.davem@davemloft.net>
	<20090127074048.GA4197@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, herbert@gondor.apana.org.au, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42155
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753502AbZA3Vma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 16:42:30 -0500
In-Reply-To: <20090127074048.GA4197@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 27 Jan 2009 07:40:48 +0000

> I think the main problem is to respect put_page() more, and maybe you
> mean to add this to your allocator too, but using slab pages for this
> looks a bit complex to me, but I can miss something.

Hmmm, Jarek's comments here made me realize that we might be
able to do some hack with cooperation with SLAB.

Basically the idea is that if the page count of a SLAB page
is greater than one, SLAB will not use that page for new
allocations.

It's cheesy and the SLAB developers will likely barf at the
idea, but it would certainly work.

Back to real life, I think long term the thing to do is to just do the
cached page allocator thing we'll be doing after Jarek's socket page
patch is integrated, and for best performance the driver has to
receive it's data into pages, only explicitly pulling the ethernet
header into the linear area, like NIU does.
