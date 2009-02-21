From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: NAPI of many interfaces with just an interruption source
Date: Sun, 22 Feb 2009 08:19:22 +1100
Message-ID: <1235251162.8805.212.camel@pasglop>
References: <20090221131251.GA28821@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, gotzoncabanes@gmail.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57933 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753527AbZBUVTh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Feb 2009 16:19:37 -0500
In-Reply-To: <20090221131251.GA28821@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Ben has just done exactly the same thing for his driver so he
> can tell you all about it and how to use his generic function :)

Right, you can look how it's done in ibm_newemac. There's basically
a "dummy" netdev which is created to handle the NAPI on behalf of
the real ones. The new core function init_dummy_netdev() will set
up that dummy netdev for you.

If you look at how I do it in emac, the actual ports "register"
internally with that "mal" module so that I can "poll" them when
the main NAPI is polled.

Cheers,
Ben.





