From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Patch for tbench regression.
Date: Mon, 29 Sep 2008 10:07:12 -0700
Message-ID: <48E10B40.4000205@hp.com>
References: <20080928211530.GA9341@2ka.mipt.ru>	<20080929031244.GA22619@gondor.apana.org.au>	<20080929053605.GA21663@2ka.mipt.ru>	<20080929054052.GA23600@gondor.apana.org.au>	<20080929055203.GA3460@2ka.mipt.ru>	<20080929064006.GA23967@gondor.apana.org.au>	<20080929064518.GA10653@2ka.mipt.ru>	<20080929070213.GA24146@gondor.apana.org.au>	<20080929094352.GA25273@gondor.apana.org.au> <20080929095126.GA25371@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	Mel Gorman <mel@csn.ul.ie>, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@marvell.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:44100 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbYI2RHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 13:07:23 -0400
In-Reply-To: <20080929095126.GA25371@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sigh - email reading timing....  anyway

> It seems that netperf is issuing 16384-byte writes and as such
> we're sending the packets out immediately so TSO doesn't get a
> chance to merge the data.  Running netperf with -m 65536 makes
> TSO beat non-TSO by 6293Mb/s to 4761Mb/s.

By default, netperf's TCP_STREAM test will use whatever 
getsockopt(SO_SNDBUF) reports just after the data socket is created. 
The choice was completely arbitrary and burried deep in the history of 
netperf.

For evaluating changes, it would probably be a good idea to test a 
number of settings for the test-specific -m option.  Of course I have no 
good idea what those values should be.  There is the tcp_range_script 
(might be a bit dusty today) but those values are again pretty arbitrary.

It would probably be a good idea to include the TCP_RR test.

happy benchmarking,

rick jones

As an asside - I would be interested in hearing peoples' opinions 
(offline) on a future version of netperf possibly violating the 
principle of least surprise and automatically including CPU utilization 
if the code is running on a system which does not require calibration...
