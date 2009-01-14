From: Rick Jones <rick.jones2@hp.com>
Subject: Re: sendfile()? Re: SO_LINGER dead: I get an immediate RST on 2.6.24?
Date: Wed, 14 Jan 2009 00:08:42 -0800
Message-ID: <496D9D8A.8080804@hp.com>
References: <20090113063205.GA26047@gondor.apana.org.au>	<20090113015614.3b815ad7.billfink@mindspring.com>	<496C3D5C.7080407@hp.com> <20090114030531.a29680c6.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	ilpo.jarvinen@helsinki.fi, zbr@ioremap.net,
	bert.hubert@netherlabs.nl, h.willstrand@gmail.com,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:7370 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755100AbZANIIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 03:08:53 -0500
In-Reply-To: <20090114030531.a29680c6.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>How likely is it that the "additional small delay" above would be much 
>>less than waiting for a read return of zero after a shutdown(SHUT_WR) call?
> 
> 
> I'm not sure I understand what you're getting at.  I did consider doing
> something like what you suggested, but in the end decided it was simpler
> to deal with a fully ESTABLISHED connection, than worrying about possible
> races with a socket being (partially or fully) closed.

Ostensibly, using a shutdown(SHUT_WR) and then a wait for a recv return 
of zero would take about the same length of time as polling local 
connection stats to see that there were no ostensibly unacked data - 
both will take one RTT right?  and shutdown/read has the added property 
that it will deal with zero windows automagically.

rick
