From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RFC] sctp/tcp: Question -- ICMPv4 length check (not)	redundant?
Date: Mon, 28 Jul 2008 09:14:34 -0400
Message-ID: <488DC63A.3070309@hp.com>
References: <20080727045121.GA419@gondor.apana.org.au> <20080728112527.GB7589@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, vladislav.yasevich@hp.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:23783 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbYG1NOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 09:14:37 -0400
In-Reply-To: <20080728112527.GB7589@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, I seem to be confused here.


Gerrit Renker wrote:
> Thank you for the input. To sum up,
>  * removing the per-protocol "ICMP payload too short" test and error counter
>    increment as initially suggested does not seem right;
>  * there are protocols such as IPComp which have a header length less than
>    8 bytes(and for these the test in the ICMP handler may be too much);

How so.  Either 8 bytes will be there or not.  If the 8 bytes aren't there,
we won't event make to the error handlers as it stands right now.  As is, if
the ICMP packet doesn't contain the 8 bytes, it's too short according to ICMP spec.

>  * there are protocols such as DCCP which need more than 8 bytes (at least 12)
>    to interpret the ICMP message in a meaningful way;

If you need more then 8 bytes, that protocol needs to have a check for the extra
space.  8 byte are mandatory.

>  * the requirement of having at least 8 bytes of transport-layer data available
>    is stringent (afaik) only for ICMPv4, but not ICMPv6;

Splitting hairs here, but ICMPv6 is much more stringent.  It forces you send as
close to 1280 byte error messages as possible.

>  * only TCP/SCTP seem to have a proper per-protocol "payload too short" test;

Hm..  In the standard case, these do seem to be redundant since 8 bytes are required
by ICMP spec.

>  * for DCCP, the work is actually doubled since 
>    - first the ICMP handler tests for minimally 8 bytes, 
>    - then the DCCP error handler tests for required minimum of 12 bytes.

DCCP and any other protocol that requires more error data should check for it in
its own handler.  8 bytes should be guaranteed to such handler.

What am I missing?

Thanks
-vlad

> 
> Thus the patch at the begginning of this thread should be disregarded.
> It might be worth to consider per-protocol handlers.
> 
> Gerrit
> 

