From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: rfs: record flow in TCP receiving and sending pathes
Date: Fri, 09 Jul 2010 10:51:06 -0700 (PDT)
Message-ID: <20100709.105106.226773972.davem@davemloft.net>
References: <1278660498-26587-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40750
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751840Ab0GIRuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 13:50:51 -0400
In-Reply-To: <1278660498-26587-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Fri,  9 Jul 2010 15:28:18 +0800

> rfs: record flow in TCP receiving and sending pathes
> 
> call sock_rps_record_flow() in function tcp_splice_read(), tcp_sendpage() and
> tcp_sendmsg().
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

I don't think it's wise to pepper these calls all over the place if it
is not necessary.

The only reason we vector straight to the TCP implementations of these
I/O routines is to avoid the port autobinding made by the inet_*()
functions.

But now that avoids also the RPS calls.

So it makes sense to just add a boolean state bit flag of some sort
to "struct proto" which says to avoid the autobind calls, then
make TCP vector through the inet_*() functions just like the other
inet protocols do.

Then these extra send_rps_record_flow() annotations will not be
necessary.
