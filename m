From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Network/block layer race.
Date: Fri, 28 Mar 2008 23:56:13 +0300
Message-ID: <20080328205613.GA24812@2ka.mipt.ru>
References: <20080328092036.GA11924@2ka.mipt.ru> <20080328.134053.122172549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: axboe@kernel.dk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:52159 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755186AbYC1Uww (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 16:52:52 -0400
Content-Disposition: inline
In-Reply-To: <20080328.134053.122172549.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Fri, Mar 28, 2008 at 01:40:53PM -0700, David Miller (davem@davemloft.net) wrote:
> If content protection is desired, higher level things are needed.
> For example, SAMBA only uses sendfile() if the remote client
> has an OP lock on the file in question.

What I propose is to inform sender about when page is transmitted and
received on the other side via implicit acks, which are provided already
by tcp, but is not provided to higher layer.
We can use it for sendfile and thus do not require higher
layer 'distributed' locks, i.e. sync some state between hosts to inform
that data was succesfully received. Patch would be minimal, just export
sock_wfree() and setup different skb destructor if sk_sock_data is
provided, that will allow for special users (like the same samba) to use
->sendpage() path too (with some changes in the code of course, but that
is worth whole page copying).

-- 
	Evgeniy Polyakov
