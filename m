From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Mon, 27 Sep 2010 16:02:22 +0800
Message-ID: <20100927080222.GA31309@gondor.apana.org.au>
References: <20100926131717.GA13046@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	"David S. Miller" <davem@davemloft.net>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:40585 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419Ab0I0IC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 04:02:26 -0400
Content-Disposition: inline
In-Reply-To: <20100926131717.GA13046@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy Tarreau <w@1wt.eu> wrote:
>
> Looking more closely, I noticed that in traces showing the issue,
> the client was sending an additional CRLF after the data in a
> separate packet (permitted eventhough not recommended).

Where is this permitted? RFC2616 says:

	Certain buggy HTTP/1.0 client implementations generate
	extra CRLF's after a POST request. To restate what is
	explicitly forbidden by the BNF, an HTTP/1.1 client MUST
	NOT preface or follow a request with an extra CRLF. 

Now if you want to support these broken clients it should be
as simple as doing the read that Eric suggested but with the
proviso that you only have to read one CRLF before closing.

This workaround for broken HTTP clients definitely does not belong
in the TCP stack.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
