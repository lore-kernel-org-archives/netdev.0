From: David Miller <davem@davemloft.net>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Mon, 27 Sep 2010 00:42:39 -0700 (PDT)
Message-ID: <20100927.004239.58422076.davem@davemloft.net>
References: <20100927053901.GL12373@1wt.eu>
	<20100926.234202.241938788.davem@davemloft.net>
	<20100927073443.GR12373@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35525
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753744Ab0I0HmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 03:42:19 -0400
In-Reply-To: <20100927073443.GR12373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Mon, 27 Sep 2010 09:34:43 +0200

> On Sun, Sep 26, 2010 at 11:42:02PM -0700, David Miller wrote:
>> just because your application
>> doesn't want to wait around to sink a pending newline character?
> 
> it's not that it *doesn't want* to wait for the pending newline character,
> it's that this character has no reason to be there and cannot be predicted,
> and even when you find it, nothing tells the application that it's the last
> one.
> 
>> Is that what this boils down to?
> 
> No, it's the opposite in fact, the goal is to ensure we can reliably
> release the whole connection ASAP instead of being forced to sink any
> possible data that may come from it and that will not be consumed nor
> will lead to a reset. Look :

I still think it's completely broken that you want to close a
connection for which data is still going to arrive.

And I really can't think of why this can't be solved at the
application level.

Either there is an application level ACK that you have to wait for
anyways, or there isn't and you receive the entire request packet
before you start sending the data.

If there is some kind of unpredictable "dribbling" after the request
arrives, you really have to fix that.

I honestly have no sympathy for an application level protocol that
works this way, and I don't think the kernel is the place where this
should be handled.

Please don't exhaust me any further on this issue, thank you.
