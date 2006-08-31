From: David Miller <davem@davemloft.net>
Subject: LRO fix needed
Date: Thu, 31 Aug 2006 16:42:27 -0700 (PDT)
Message-ID: <20060831.164227.71090271.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18610
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932422AbWHaXm2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 19:42:28 -0400
To: Ananda.Raju@neterion.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ananda, Herbert Xu recently found a problem in the TCP stack
input path for LRO capable receive paths.

The issue is that the receive MSS estimator in
tcp_measure_rcv_mss() uses skb->len for the MSS
estimation.  This is wrong for LRO frames.

Herbert noticed this using Xen which pused TSO frames
on output back into the destination TCP stack on input
so it looks exactly like LRO.

His fix to tcp_measure_rcv_mss() is to use
skb_shared_info(skb)->gso_size if it is non-zero,
else skb->len, in the assignment to "len".

So could you please make the S2io driver LRO path
set skb_shared_info(skb)->gso_size appropriately?
Probably the easiest is to use the length of the
first frag of a multiple frag LRO sequence.

Also, could we have a linux/MAINTAINERS entry added
for the S2io driver?

Thanks.
