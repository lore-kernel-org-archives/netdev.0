From: David Miller <davem@davemloft.net>
Subject: Re: maximum buffer size for splice(2) tcp->pipe?
Date: Wed, 14 Jan 2009 20:58:39 -0800 (PST)
Message-ID: <20090114.205839.20689555.davem@davemloft.net>
References: <20090113123702.ad29cd13.akpm@linux-foundation.org>
	<496D2078.9080302@cosmosbay.com>
	<496D25F8.2080505@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, Volker.Lendecke@SerNet.DE,
	linux-kernel@vger.kernel.org, sfrench@us.ibm.com,
	jens.axboe@oracle.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47382
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753343AbZAOE6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 23:58:38 -0500
In-Reply-To: <496D25F8.2080505@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 14 Jan 2009 00:38:32 +0100

> [PATCH] net: splice() from tcp to socket should take into account O_NONBLOCK
> 
> Instead of using SPLICE_F_NONBLOCK to select a non blocking mode both on
> source tcp socket and pipe destination, we use the underlying file flag (O_NONBLOCK)
> for selecting a non blocking socket.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

This needs at least some more thought.

It seems, for one thing, that this change will interfere with the
intentions of the code in splice_dirt_to_actor which goes:

	/*
	 * Don't block on output, we have to drain the direct pipe.
	 */
	sd->flags &= ~SPLICE_F_NONBLOCK;
