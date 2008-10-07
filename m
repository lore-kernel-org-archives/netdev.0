From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Tue, 07 Oct 2008 15:46:20 -0700 (PDT)
Message-ID: <20081007.154620.37617395.davem@davemloft.net>
References: <E1KmLCH-0003E2-Ch@gondolin.me.apana.org.au>
	<48EA2C71.6070509@bull.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	dlezcano@fr.ibm.com
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43049
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752731AbYJGWqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 18:46:44 -0400
In-Reply-To: <48EA2C71.6070509@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Mon, 06 Oct 2008 17:19:13 +0200

> I guess you know a lot better than me the history behind this piece of
> code and why it was done this way.

Or maybe Herbert doesn't know :-)

I wrote this crap, and I can't remember why I decided to drop
the RTNL semaphore so early and go directly to that todo lock.
Maybe it was purely because of how the interfaces are arranged
and I considered it ugly to drop the RTNL semaphore in the
todo list running code.   Who knows...

I'm going to scrutinize Herbert's patch some more, but this is
really a borderline change to put into 2.6.27 so late in the
RC cycle.

I want to fix this bug, but... it's risky.
