From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Mon, 27 Sep 2010 21:21:12 +0200
Message-ID: <20100927192112.GT12373@1wt.eu>
References: <20100927053901.GL12373@1wt.eu> <20100926.234202.241938788.davem@davemloft.net> <20100927073443.GR12373@1wt.eu> <20100927.004239.58422076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:45723 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933430Ab0I0TVQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Sep 2010 15:21:16 -0400
Content-Disposition: inline
In-Reply-To: <20100927.004239.58422076.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 27, 2010 at 12:42:39AM -0700, David Miller wrote:
> I still think it's completely broken that you want to close a
> connection for which data is still going to arrive.
> 
> And I really can't think of why this can't be solved at the
> application level.
> 
> Either there is an application level ACK that you have to wait for
> anyways, or there isn't and you receive the entire request packet
> before you start sending the data.
> 
> If there is some kind of unpredictable "dribbling" after the request
> arrives, you really have to fix that.
> 
> I honestly have no sympathy for an application level protocol that
> works this way, and I don't think the kernel is the place where this
> should be handled.
> 
> Please don't exhaust me any further on this issue, thank you.

David,

I don't want to exhaust you on the issue and I really understand that
you quickly read my explanations and don't get the issues.

Two quick facts :
  - HTTP allows the client to send whatever it wants whenever it wants
    and allows the server to close after whatever response it wants.
    Thus the server cannot predict that the client will talk.

  - orphans don't work anymore, period. Why not remove that whole code
    if you pretend it must not be used ? You still did not reply to this
    point, and I'm sure you will still not respond to this, probably
    because you've realized that there is indeed a bug which is probably
    not easy to solve, given the limited use it has.

Please, wait for a moment when you have a bit more spare time and check
what the orphans may be used for with this issue => nothing. That's why
I'm trying to discuss a possible fix.

Thanks,
Willy

