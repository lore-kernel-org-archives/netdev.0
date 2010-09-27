From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Mon, 27 Sep 2010 22:00:18 +0200
Message-ID: <20100927200018.GY12373@1wt.eu>
References: <20100926131717.GA13046@1wt.eu> <20100927080222.GA31309@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:45732 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755947Ab0I0UAZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Sep 2010 16:00:25 -0400
Content-Disposition: inline
In-Reply-To: <20100927080222.GA31309@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

On Mon, Sep 27, 2010 at 04:02:22PM +0800, Herbert Xu wrote:
> Willy Tarreau <w@1wt.eu> wrote:
> >
> > Looking more closely, I noticed that in traces showing the issue,
> > the client was sending an additional CRLF after the data in a
> > separate packet (permitted eventhough not recommended).
> 
> Where is this permitted? RFC2616 says:
> 
> 	Certain buggy HTTP/1.0 client implementations generate
> 	extra CRLF's after a POST request. To restate what is
> 	explicitly forbidden by the BNF, an HTTP/1.1 client MUST
> 	NOT preface or follow a request with an extra CRLF. 

And the paragraph just before says :

   In the interest of robustness, servers SHOULD ignore any empty
   line(s) received where a Request-Line is expected. In other words, if
   the server is reading the protocol stream at the beginning of a
   message and receives a CRLF first, it should ignore the CRLF.

That's the usual principle : be strict with what you send and be liberal
with what you accept. Also, clients are encouraged to pipeline requests
over a connection and may very legally send a new request before the
current response is completely received.

> This workaround for broken HTTP clients definitely does not belong
> in the TCP stack.

I'm not trying to workaround broken HTTP clients using the TCP stack,
that's contrary to my principles. I want to ensure that the orphans code
that should legitimately be used can be used. And if orphans work again
as advertised, then the HTTP issue that revealed the issue automatically
gets fixed.

Regards,
Willy

