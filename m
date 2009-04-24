From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Fri, 24 Apr 2009 10:13:52 -0700
Message-ID: <49F1F350.2080402@hp.com>
References: <20090415.030213.249634462.davem@davemloft.net>	<49E5DABB.9070806@myri.com> <49E64BE4.1050908@myri.com>	<20090415.164248.188350673.davem@davemloft.net>	<20090416085022.GA19731@gondor.apana.org.au>	<49EE1C32.1060202@myri.com>	<20090422104811.GA30981@gondor.apana.org.au>	<49EF39B4.1040607@myri.com>	<20090424054557.GA24575@gondor.apana.org.au> <49F1B468.7020605@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:21865 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753023AbZDXRNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 13:13:55 -0400
In-Reply-To: <49F1B468.7020605@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This is strange.  I wonder if it might be a cache footprint issue?
> My intentionally weak receiver is an athlon64 x2 "Toledo", and
> has only 512KB L2 cache.  I can re-test with a core-2 based Xeon.

A point about netperf :)  By default, it will use one more buffer than the 
initial size of the socket buffer divided by the send/recv buffer size - this 
goes back to days of copy-avoidance, a flavor of which can be found in reading:

ftp://ftp.cup.hp.com/dist/networking/briefs/copyavoid.pdf

particularly section 3.2.  It can be overridden with the global -W option:

     -W send,recv      Set the number of send,recv buffers

Of course, this will interact with other things such as:

The default send/recv size will be the send/recv socket buffer size. That can be 
overridden with the test-specific -m/-M options.

The default socket buffer size will be whatever the system gives it.  That can be 
overridden with the test-specific -s/-S options.

So, the various options can have a non-trivial effect on the cache footprint of 
the data netperf is shoving around.

rick jones
