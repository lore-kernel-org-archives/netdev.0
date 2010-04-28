From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] random SYN drops causing connect() delays
Date: Tue, 27 Apr 2010 18:56:02 -0700 (PDT)
Message-ID: <20100427.185602.221594952.davem@davemloft.net>
References: <20100412080633.GA27418@bombadil.infradead.org>
	<20100412083903.GA19763@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43538
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754351Ab0D1Bz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 21:55:56 -0400
In-Reply-To: <20100412083903.GA19763@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@infradead.org>
Date: Mon, 12 Apr 2010 04:39:03 -0400

> On Mon, Apr 12, 2010 at 04:06:33AM -0400, Thomas Graf wrote:
>>  - While the issue is appearing, the acceptq seems to be overflowing. Both
>>    LISTENOVERFLOWS and LISTENDROPS are increasing although not by the exact
>>    number of delay occurences. inetdiag reports sk_max_ack_backlog to be 0
>>    therefore one possibility that comes to mind is that sk_ack_backlog
>>    underflows due to a race.
> 
> Forget about the underflow thought, inetdiag was reporting falsely.
> sk_max_ack_backlog is set to 128 as it should and the listen overflow
> happens normally. Still the fact remains that while the issue is appearing
> listen overflows are counted.

I can't reproduce on my system even with sched_child_runs_first set to '1'.

Are you running identd or something like that which intercepts the connections
to port 22 before 'sshd' actually gets it?
