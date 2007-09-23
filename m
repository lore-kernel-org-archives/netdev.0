From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: incorrect cksum with tcp/udp on lo with 2.6.20/2.6.21/2.6.22
Date: Sun, 23 Sep 2007 12:39:36 +0800
Message-ID: <E1IZJFo-0006ta-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.64.0709131942370.27961@bizon.gios.gov.pl>
Cc: netdev@vger.kernel.org
To: olel@ans.pl (Krzysztof Oledzki)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4452 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752926AbXIWEjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Sep 2007 00:39:44 -0400
In-Reply-To: <Pine.LNX.4.64.0709131942370.27961@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Oledzki <olel@ans.pl> wrote:
> 
> It seems that after some not very recent changes udp and tcp packes 
> carring data send by a loopback have incorrect cksum:

This correct.  The loopback interfaces has the no checksum flag
set so we only provide a partial checksum on output (i.e., the
pseudoheader without the payload).

We even export this to user-space via a flag.  So you should fix
tcpdump to read this flag and ignore the checksum.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
