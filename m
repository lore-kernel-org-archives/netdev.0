From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Fri, 30 Jan 2009 14:15:31 -0800 (PST)
Message-ID: <20090130.141531.56578757.davem@davemloft.net>
References: <20090130215920.GC31355@1wt.eu>
	<20090130.140346.159984249.davem@davemloft.net>
	<20090130221346.GE31355@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, zbr@ioremap.net, herbert@gondor.apana.org.au,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49363
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754069AbZA3WPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 17:15:33 -0500
In-Reply-To: <20090130221346.GE31355@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Fri, 30 Jan 2009 23:13:46 +0100

> On Fri, Jan 30, 2009 at 02:03:46PM -0800, David Miller wrote:
> > Any NIC, even the dumbest ones, can be made to receive into pages.
> 
> OK I thought that it was not always easy to split between headers
> and payload. I know that myri10ge can be configured to receive into
> either skbs or pages, but I was not sure about the real implications
> behind that.

For a dumb NIC you wouldn't split, you'd receive directly, the
entire packet, into part of a page.

Then right befire you give it to the stack, you pull the ethernet
header from the page into the linear area.
