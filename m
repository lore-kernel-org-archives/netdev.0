From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: all this business about ->sk_sleep
Date: Tue, 17 Jun 2008 15:35:11 +0400
Message-ID: <20080617113509.GA8982@2ka.mipt.ru>
References: <20080617.025446.180013373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:46630 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751386AbYFQLfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 07:35:09 -0400
Content-Disposition: inline
In-Reply-To: <20080617.025446.180013373.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Tue, Jun 17, 2008 at 02:54:46AM -0700, David Miller (davem@davemloft.net) wrote:
> net/unix/af_unix.c:	newsk->sk_sleep		= &newu->peer_wait;
> 
> The only thing that uses something other than &sk->sk_socket->wait
> for sk->sk_sleep is AF_UNIX.  So that's a useful discovery and
> we may be able to get rid of sk->sk_sleep somehow.  I'll try to
> launch a full investiation into how and why AF_UNIX uses a special
> wait queue.

Its 'pipe way', which allows to wake reader when performing write
on writer and vice versa.

-- 
	Evgeniy Polyakov
