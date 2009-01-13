From: Rick Jones <rick.jones2@hp.com>
Subject: Re: sendfile()? Re: SO_LINGER dead: I get an immediate RST on 2.6.24?
Date: Mon, 12 Jan 2009 23:06:04 -0800
Message-ID: <496C3D5C.7080407@hp.com>
References: <20090113063205.GA26047@gondor.apana.org.au> <20090113015614.3b815ad7.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	ilpo.jarvinen@helsinki.fi, zbr@ioremap.net,
	bert.hubert@netherlabs.nl, h.willstrand@gmail.com,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:35373 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626AbZAMHGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 02:06:11 -0500
In-Reply-To: <20090113015614.3b815ad7.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink wrote:
> On Tue, 13 Jan 2009, Herbert Xu wrote:
> 
> 
>>Bill Fink <billfink@mindspring.com> wrote:
>>
>>>If I understand you correctly, to hit this corner case, just after
>>>the final TCP write, there would have to be no packets in flight
>>>together with a zero TCP window.  To make it more bullet-proof, I
>>>guess after seeing a zero tcpi_unacked, an additional small delay
>>>should be performed, and then rechecking for a zero tcpi_unacked.
>>>I don't see anything else obvious (to me anyway) in the tcp_info
>>>that would be particularly helpful in handling this.
>>
>>What's wrong with idiag_wqueue? Isn't that a much more direct
>>way to get this?
> 
> 
> I'm not familiar with idiag_wqueue, but it sounds like it has something
> to do with INET_DIAG/INET_TCP_DIAG.  It was a long time ago, but I seem
> to recall that using INET_DIAG had a negative impact on performance,
> and since the main point of nuttcp is to measure TCP/UDP performance,
> that would be contrary to its primary purpose.  Also, I don't want to
> rely on something that's not guaranteed to be part of the running kernel.

How likely is it that the "additional small delay" above would be much 
less than waiting for a read return of zero after a shutdown(SHUT_WR) call?

rick jones
