From: David Miller <davem@davemloft.net>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Sun, 26 Sep 2010 15:19:46 -0700 (PDT)
Message-ID: <20100926.151946.39196112.davem@davemloft.net>
References: <20100926184914.GC12373@1wt.eu>
	<1285534871.2357.19.camel@edumazet-laptop>
	<20100926214614.GD12373@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56893
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757663Ab0IZWT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 18:19:26 -0400
In-Reply-To: <20100926214614.GD12373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Sun, 26 Sep 2010 23:46:14 +0200

> Eventhough we optimize for the most common cases, that doesn't save us
> from having to support the legacy cases.

There is nothing "legacy" about performing a proper reset when data
was lost.

Otherwise the peer has every right to believe that the data it sent
was sinked all the way to the remote application.

Which it wasn't.

Reset is the only appropriate action in this situation.

If the application layer protocol you're dealing with is so broken
that a multi-megabyte transfer happens even when it gets an error
indication, that really isn't the kernels problem and it is very clear
where the "fix" lies and that in the application layer proptocol and
handling.
