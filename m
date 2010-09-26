From: David Miller <davem@davemloft.net>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Sun, 26 Sep 2010 15:13:46 -0700 (PDT)
Message-ID: <20100926.151346.112585478.davem@davemloft.net>
References: <20100926131717.GA13046@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35630
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757663Ab0IZWN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 18:13:26 -0400
In-Reply-To: <20100926131717.GA13046@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Sun, 26 Sep 2010 15:17:17 +0200

> I've read RFC 2525 #2.17 and it shows quite interesting examples of what
> it wanted to protect against. However, the recommendation did not consider
> the fact that there could be some unacked pending data in the outgoing
> buffers.

It doesn't matter if there is any pending data still outgoing when
we received this data after close().

The issue is that the reliable transport nature of TCP has been
violated, and as such the entire connection's reliability has
been compromised.

The only appropriate response is a full reset.

As Eric said, your only option is to fully sync the data coming
from the peer.
