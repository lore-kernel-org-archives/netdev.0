From: David Miller <davem@davemloft.net>
Subject: Re: TCP_SKB_CB(skb)->flags = iph->tos ?
Date: Wed, 04 Jun 2008 15:26:07 -0700 (PDT)
Message-ID: <20080604.152607.170576716.davem@davemloft.net>
References: <200805302353.56440.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40466
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752327AbYFDW0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 18:26:08 -0400
In-Reply-To: <200805302353.56440.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Fri, 30 May 2008 23:53:56 +0300

> 
> tcp_v4_rcv says: TCP_SKB_CB(skb)->flags = iph->tos;
> 
> I am probably missing something obvious, but shouldn't flags be initialized 
> with the TCP headers instead of the IP TOS value?

On packet output ->flags holds the TCP header flags, on packet input
it holds the TOS field for testing ECN flags.

You could have had a look at how the ->flags field is used on TCP
output vs. TCP input processing to get a better idea of what might be
going on here.

That's exactly how I figured it out, I didn't know the answer either,
but constantly I'm doing simple searches for people and learning the
code for other people it seems even when I really don't even have
the time to do so :-/
