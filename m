From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Bug 8013] New: select for write hangs on a socket after write returned ECONNRESET
Date: Thu, 22 Feb 2007 16:46:21 +0300
Message-ID: <20070222134620.GC5208@2ka.mipt.ru>
References: <20070216183426.GA3138@2ka.mipt.ru> <20070221.224543.95508003.davem@davemloft.net> <20070222121427.GA29455@2ka.mipt.ru> <20070222.053138.74748069.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59752 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932069AbXBVNr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 08:47:59 -0500
Content-Disposition: inline
In-Reply-To: <20070222.053138.74748069.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 22, 2007 at 05:31:38AM -0800, David Miller (davem@davemloft.net) wrote:
> TCP_CLOSE is where we end up on a non-error close too, this has
> the same kind of bug as your previous attempt to set POLLERR
> here.
> 
> One side gets TCP_TIMEWAIT the other goes straight to TCP_CLOSE.
> 
> It really is not possible to change current semantics, they are the
> best possible unfortunately.

AS a last attempt - we can have a sockt flag set when sk-err is
installed in tcp_reset(), and tcp_poll() will set POLLERR if that flag
exist (just like it checks for sk_err, which is cleared in tcp_sendmsg()
when error is being returned).

-- 
	Evgeniy Polyakov
