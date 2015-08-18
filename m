From: David Miller <davem@davemloft.net>
Subject: Re: [net-next RFC] net: ipv4: Send IGMP messages from highest
 scoped address
Date: Mon, 17 Aug 2015 21:31:58 -0700 (PDT)
Message-ID: <20150817.213158.1038537149649115817.davem@davemloft.net>
References: <1439827764-29129-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbbHREb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 00:31:59 -0400
In-Reply-To: <1439827764-29129-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 17 Aug 2015 18:09:24 +0200

> This is RFC because i personally don't know if this is the best fix.
> The patch restores previous behavior, while still keeping the bug fix.
> 
> It is not obvious what is the correct source address for an IGMP
> message when an interface has multiple addresses. IGMP messages are
> sent either spontaneously, or as a result of a query. It could be
> argued that when replying to a query, an address take from the same
> subnet as the querier should be used. Doing this adds complexity for a
> corner case which does not seem to effect people. In the spontaneous
> case, there is no such hint, so an address has to be picked some other
> way. Taking the highest scope address seems reasonable, and works for
> me.

Yes, unfortunately almost no guidance is given in this area in the
various RFCs.

Except that one recommended way to avoid forged IGMPs is to reject
any IGMP that has a source address no on that interface's subnet.

And if people actually do that, then the link scope address is the
best address to use and that is what we do now if I understand things
correctly.
