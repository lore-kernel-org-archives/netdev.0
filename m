From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v6 4/7 RFC] TCPCT part 1d: define TCP
 cookie option, extend existing struct's
Date: Mon, 16 Nov 2009 19:15:22 -0800 (PST)
Message-ID: <20091116.191522.178198674.davem@davemloft.net>
References: <4B01BF65.1010203@gmail.com>
	<4B01CD8D.1000305@gmail.com>
	<4B01D17C.4010407@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: william.allen.simpson@gmail.com, netdev@vger.kernel.org,
	joe@perches.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34642
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752373AbZKQDPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 22:15:05 -0500
In-Reply-To: <4B01D17C.4010407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 16 Nov 2009 23:26:04 +0100

> So adding DATA to SYN packets might be problematic for part of our tcp stack.

I can almost guarentee it won't work.  For one thing getting a SACK
response to a SYN+DATA packet will explode quite nicely for one thing.

A lot of the other retransmit queue handling would need to be audited
as well.  So much code assumes that if we see sent data in the
retransmit queue, there won't be SYN or SYN+ACK things in there to
contend with.
