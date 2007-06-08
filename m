From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RFC] network splice receive
Date: Fri, 08 Jun 2007 01:06:29 -0700 (PDT)
Message-ID: <20070608.010629.52902577.davem@davemloft.net>
References: <20070607105159.GV4735@kernel.dk>
	<20070607145818.GA26491@2ka.mipt.ru>
	<20070608074823.GG7341@kernel.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org
To: jens.axboe@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46419
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S968652AbXFHIGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 04:06:14 -0400
In-Reply-To: <20070608074823.GG7341@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jens Axboe <jens.axboe@oracle.com>
Date: Fri, 8 Jun 2007 09:48:24 +0200

> Perhaps it's possible to solve this at a different level - can we hang
> on to the skb until the pipe buffer has been consumed, and prevent reuse
> that way? Then we don't have to care what backing the skb has, as long
> as it (and its data) isn't being reused until we drop the reference to
> it in sock_pipe_buf_release().

Depending upon whether the pipe buffer consumption is bounded of not,
this will jam up the TCP sender because the SKB data allocation is
charged against the socket send buffer allocation.
