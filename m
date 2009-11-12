From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [next-next-2.6] net: configurable device name hash
Date: Wed, 11 Nov 2009 18:36:26 -0800 (PST)
Message-ID: <20091111.183626.202530131.davem@davemloft.net>
References: <20091111.124235.243348591.davem@davemloft.net>
	<20091111133342.1011e16a@nehalam>
	<200911112347.41425.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52893
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759975AbZKLCgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 21:36:00 -0500
In-Reply-To: <200911112347.41425.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Wed, 11 Nov 2009 23:47:41 +0200

> We could use a similar function that will work in the per namespace
> initialization context, but this might upset net namespace folks
> since we will get a large hash for every namespace.

Use kzalloc(), that's sufficient for a 64K or so hash table which is
way more than you ever will need.

Use the GFP_* flags that will silently (ie. without a log message)
fail, and divide by two until you successfully allocate the table if
you're worried about memory fragmentation at allocation time.

This is so straightforward, I can't believe we're talking so much
about how to implement this, it's a 15 minute hack :-)
