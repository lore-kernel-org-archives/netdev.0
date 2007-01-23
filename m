From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: why would EPIPE cause socket port to change?
Date: Tue, 23 Jan 2007 12:26:52 -0800
Message-ID: <20070123122652.484c05b3@freekitty>
References: <Pine.LNX.4.64.0701221954250.11520@twinlark.arctic.org>
	<E1H9ES2-0006uJ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dean@arctic.org (dean gaudet), netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:53478 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933095AbXAWU3P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 15:29:15 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1H9ES2-0006uJ-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 23 Jan 2007 16:44:10 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> dean gaudet <dean@arctic.org> wrote:
> > in the test program below the getsockname result on a TCP socket changes 
> > across a write which produces EPIPE... here's a fragment of the strace:
> > 
> > getsockname(3, {sa_family=AF_INET, sin_port=htons(37636), sin_addr=inet_addr("127.0.0.1")}, [17863593746633850896]) = 0
> > ...
> > write(3, "hi!\n", 4)                    = 4
> > write(3, "hi!\n", 4)                    = -1 EPIPE (Broken pipe)
> > --- SIGPIPE (Broken pipe) @ 0 (0) ---
> > getsockname(3, {sa_family=AF_INET, sin_port=htons(59882), sin_addr=inet_addr("127.0.0.1")}, [16927060683038654480]) = 0
> > 
> > why does the port# change?  this is on 2.6.19.1.
> 
> Prior to the last write, the socket entered the CLOSED state meaning
> that the old port is no longer allocated to it.  As a result, the
> last write operates on an unconnected socket which causes a new local
> port to be allocated as an autobind.  It then fails because the socket
> is still not connected.

Why does write cause an autobind? One would think that on a
SOCK_STREAM socket, the write should just fail with ENOTCONN


> 
> So any attempt to run getsockname after an error on the socket is
> simply buggy.
> 
> Cheers,


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
