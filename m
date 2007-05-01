From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH] TCP FIN gets dropped prematurely, results in ack storm
Date: Tue, 1 May 2007 12:49:35 -0400
Message-ID: <20070501164935.GC1751@kvack.org>
References: <20070501151354.GB1751@kvack.org> <20070501162050.GB21896@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:35755 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754759AbXEAQtp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 12:49:45 -0400
Content-Disposition: inline
In-Reply-To: <20070501162050.GB21896@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 01, 2007 at 08:20:50PM +0400, Evgeniy Polyakov wrote:
> > http://www.kvack.org/~bcrl/ack-storm.log .  As near as I can tell, a 
> > similar effect can occur between two Linux boxes if the right packets get 
> > reordered/dropped during connection teardown.
> 
> Could you archive 24Mb file or cut more precise bits out of it?

The interesting bits are the first 10 lines.

> According to your patch, several packets with fin bit might be sent,
> including one with data. If another host does not receive fin
> retransmit, then that logic is broken, and it can not be fixed by
> duplicating fins, I would even say, that remote box should drop second
> packet with fin, while it can carry data, which will break higher
> connection logic.

The FIN hasn't been ack'd by the other side, though and yet Linux is no 
longer transmitting packets with it sent.  Read the beginning of the trace.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <zyntrop@kvack.org>.
