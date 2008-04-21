From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/4] net: enable timestamps on a per-socket basis
Date: Sun, 20 Apr 2008 23:03:56 -0700 (PDT)
Message-ID: <20080420.230356.238029889.davem@davemloft.net>
References: <20080421053402.GB23476@48M1231.sanmateo.corp.akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: juhlenko@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56261
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751611AbYDUGDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 02:03:54 -0400
In-Reply-To: <20080421053402.GB23476@48M1231.sanmateo.corp.akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Uhlenkott <juhlenko@akamai.com>
Date: Sun, 20 Apr 2008 22:34:02 -0700

> This patchset creates a mechanism for protocols to opt in to handling
> timestamps at a higher layer, and uses this mechanism to implement
> per-socket SOCK_TIMESTAMP support for several common protocols.

Moving the timestamp up to a higher level takes away some of the
frequent use cases of timestamps, which is to detect things like the
fact that it is taking a long time for packets to get from the
top-level packet receive down to the actual protocol processing.

With your patch, it can't be used that way any more.

In fact, people are desiring timestamps which are _closer_ to when the
device actually receives the frame rather than further away.

I understand the reasons why this change is desirable from a
performance standpoint, but we really can't do this, sorry.

It's probably more tenable to do the work necessary get get named to
not enable timestamps by default.  It if really wants packet data
timestamps, it can do a gettimeofday() call right after recvmsg() as
gettimeofday() is merely a function call into the VSYSCALL page on
most platforms.

