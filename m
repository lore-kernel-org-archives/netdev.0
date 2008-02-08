From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: oops with ipcomp
Date: Fri, 8 Feb 2008 11:45:33 +0100
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD134F20D4@exch.facton.local>
References: <3C59DB883F7B0B4D8096010D45ACCD134F20BB@exch.facton.local> <20080206170717.GA20308@gondor.apana.org.au> <3C59DB883F7B0B4D8096010D45ACCD134F20C0@exch.facton.local> <20080207154437.GA7237@gondor.apana.org.au> <3C59DB883F7B0B4D8096010D45ACCD134F20CE@exch.facton.local> <20080208085836.GC14650@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:40881 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755808AbYBHKpk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 05:45:40 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080208085836.GC14650@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> No I meant the exact output of ip x p and ip x s.

I know, but as I end up every time with a tainted kernel on our
production server I didn't turn ipcomp on, but now I got it.

src Net_B dst A
	dir in priority 2088 
	tmpl src B dst A
		proto comp reqid 16394 mode tunnel
		level use 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 16393 mode transport
src Net_B dst Net_A
	dir in priority 2344 
	tmpl src B dst A
		proto comp reqid 16390 mode tunnel
		level use 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 16389 mode transport
src A dst Net_B 
	dir out priority 2088 
	tmpl src A dst B
		proto comp reqid 16394 mode tunnel
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 16393 mode transport
src Net_A dst Net_B
	dir out priority 2344 
	tmpl src A dst B
		proto comp reqid 16390 mode tunnel
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 16389 mode transport
src Net_B dst A
	dir fwd priority 2088 
	tmpl src B dst A
		proto comp reqid 16394 mode tunnel
		level use 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 16393 mode transport
src Net_B dst Net_A
	dir fwd priority 2344 
	tmpl src B dst A
		proto comp reqid 16390 mode tunnel
		level use 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 16389 mode transport

src A dst B
	proto comp spi 0x0000427e reqid 16390 mode tunnel
	replay-window 0 
	comp deflate 0x
	sel src 0.0.0.0/0 dst 0.0.0.0/0 
src B dst A
	proto comp spi 0x0000ecf0 reqid 16390 mode tunnel
	replay-window 0 
	comp deflate 0x
	sel src 0.0.0.0/0 dst 0.0.0.0/0 
src A dst B
	proto esp spi 0x53f15e96 reqid 16389 mode transport
	replay-window 32 
	auth hmac(sha1) 0x...
	enc cbc(aes) 0x...
	sel src 0.0.0.0/0 dst 0.0.0.0/0 
src B dst A
	proto esp spi 0x7b329066 reqid 16389 mode transport
	replay-window 32 
	auth hmac(sha1) 0...
	enc cbc(aes) 0x...
	sel src 0.0.0.0/0 dst 0.0.0.0/0 
src A dst B
	proto (null) spi 0x53ec987a reqid 0 mode tunnel
	replay-window 0 
	sel src 0.0.0.0/0 dst 0.0.0.0/0 
src B dst A
	proto (null) spi 0xc19ef67c reqid 0 mode tunnel
	replay-window 0 
	sel src 0.0.0.0/0 dst 0.0.0.0/0 
src A dst B
	proto comp spi 0x00001314 reqid 16394 mode tunnel
	replay-window 0 
	comp deflate 0x
	sel src 0.0.0.0/0 dst 0.0.0.0/0 
src B dst A
	proto comp spi 0x000032ff reqid 16394 mode tunnel
	replay-window 0 
	comp deflate 0x
	sel src 0.0.0.0/0 dst 0.0.0.0/0 
src A dst B
	proto esp spi 0xec7d12de reqid 16393 mode transport
	replay-window 32 
	auth hmac(sha1) 0x...
	enc cbc(aes) 0x...
	sel src 0.0.0.0/0 dst 0.0.0.0/0 
src B dst A
	proto esp spi 0x75016d2d reqid 16393 mode transport
	replay-window 32 
	auth hmac(sha1) 0x...
	enc cbc(aes) 0x...
	sel src 0.0.0.0/0 dst 0.0.0.0/0 
