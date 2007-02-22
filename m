From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 8013] New: select for write hangs on a socket after write
 returned ECONNRESET
Date: Thu, 22 Feb 2007 05:31:38 -0800 (PST)
Message-ID: <20070222.053138.74748069.davem@davemloft.net>
References: <20070216183426.GA3138@2ka.mipt.ru>
	<20070221.224543.95508003.davem@davemloft.net>
	<20070222121427.GA29455@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48757
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751604AbXBVNbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 08:31:40 -0500
In-Reply-To: <20070222121427.GA29455@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 22 Feb 2007 15:14:27 +0300

> if (sk->sk_shutdown == SHUTDOWN_MASK || sk->sk_state == TCP_CLOSE)
> 	mask |= POLLHUP;
> 
> to
> 
> if (sk->sk_shutdown == SHUTDOWN_MASK || sk->sk_state == TCP_CLOSE)
> 	mask |= POLLHUP | (sk->sk_state == TCP_CLOSE)?POLLERR:0;
> 
> 
> Thoughts?

TCP_CLOSE is where we end up on a non-error close too, this has
the same kind of bug as your previous attempt to set POLLERR
here.

One side gets TCP_TIMEWAIT the other goes straight to TCP_CLOSE.

It really is not possible to change current semantics, they are the
best possible unfortunately.
