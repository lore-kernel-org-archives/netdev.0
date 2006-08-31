From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: high latency with TCP connections
Date: Fri, 1 Sep 2006 03:29:23 +0400
Message-ID: <20060831232923.GA10036@ms2.inr.ac.ru>
References: <20060830102727.11e11453@localhost.localdomain> <20060831214635.GA2680@ms2.inr.ac.ru> <20060831151456.12a4e080@dxpl.pdx.osdl.net> <20060831.154428.35684218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:48286 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932486AbWHaXaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 19:30:01 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060831.154428.35684218.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> 2) a way to take delayed ACKs into account for cwnd growth

This part is OK now, right?


> 1) protection against ACK division

But Linux never had this problem... Congestion window was increased
only when a whole skb is ACKed, flag FLAG_DATA_ACKED. (TSO could
break this, but should not). Otherwise, this ACK just advanced snd_una
and nothing more.

This aspect of ABC is crucial for BSD. TCP_NODELAY sockets did not obey
congestion control there. From the very beginning, before slow start
it can send thousands of 1 byte segments.

The only problem of kind "too-aggressive" with Linux was that we could
develop large cwnd sending small segments, and then switch to sending
mss-sized segments. It does not look scary, to be honest. :-)

Linux had troubles with slow start even before ABC. Actually,
some of applications can suffer of the same syndrome even if ABC disabled.
With ABC it becomes TROUBLE, cwnd has no chances to develop at all.

Probably, aspect 1 of ABC just should be disabled. And the first my suggestion
looks working too.

Alexey
