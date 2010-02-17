From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 4/7] tcp: input header length, prediction, and
 timestamp bugs
Date: Wed, 17 Feb 2010 15:50:30 -0800 (PST)
Message-ID: <20100217.155030.110521237.davem@davemloft.net>
References: <4B7791CF.9030201@gmail.com>
	<4B77966F.1030203@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, andi@firstfloor.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49530
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756610Ab0BQXuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 18:50:17 -0500
In-Reply-To: <4B77966F.1030203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Sun, 14 Feb 2010 01:21:35 -0500

> Don't use output calculated tp->tcp_header_len for input decisions.
> While the output header is usually the same as the input (same options
> in both directions), that's a poor assumption. In particular, Sack
> will
> be different. Newer options are not guaranteed.

And when SACK is present, tp->tcp_header_len will not match, and
therefore we won't do the header prediction fast path, what is what we
want.

And, SACK presence doesn't change tp->tcp_header_len on transmit.

Therefore, I see no need at all for this change.
