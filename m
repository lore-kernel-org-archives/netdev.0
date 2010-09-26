From: David Miller <davem@davemloft.net>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Sun, 26 Sep 2010 15:14:47 -0700 (PDT)
Message-ID: <20100926.151447.183063167.davem@davemloft.net>
References: <1285520567.2530.8.camel@edumazet-laptop>
	<20100926174014.GA12373@1wt.eu>
	<20100926191632.GB13046@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35635
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757671Ab0IZWO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 18:14:27 -0400
In-Reply-To: <20100926191632.GB13046@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Sun, 26 Sep 2010 21:16:32 +0200

> On Sun, Sep 26, 2010 at 07:40:15PM +0200, Willy Tarreau wrote:
>> 3) when an ACK comes from the other side, either it's below our last
>>    seq, and we simply ignore it, just as if we were in TIME_WAIT, or
>>    it is equal to the last seq and indicates that it's now safe to
>>    reset ; we would then just send the RST to notify the other side
>>    that the data it sent were not read. The connection can then either
>>    be destroyed or put in TIME_WAIT. It's the point where the connection
>>    normally switches from FIN_WAIT1 to FIN_WAIT2, since the FIN has been
>>    acked. The only difference is that we don't need a FIN_WAIT2 state
>>    for an orphan.
> 
> In fact, the following patch seems to provide the expected result :

There is no way I'm applying this.

Pending outgoing data means nothing, and not sending out the RST is
wrong because there will be no notification to the peer that you
decided to close and ignore the data stream the peer sent, and thus
data was lost.
