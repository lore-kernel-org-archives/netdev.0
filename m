From: David Miller <davem@davemloft.net>
Subject: Re: why would EPIPE cause socket port to change?
Date: Tue, 23 Jan 2007 22:30:23 -0800 (PST)
Message-ID: <20070123.223023.45743778.davem@davemloft.net>
References: <E1H9ES2-0006uJ-00@gondolin.me.apana.org.au>
	<20070123122652.484c05b3@freekitty>
	<20070124055833.GA17989@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, dean@arctic.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53508
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932793AbXAXGaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 01:30:25 -0500
In-Reply-To: <20070124055833.GA17989@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 24 Jan 2007 16:58:33 +1100

> On Tue, Jan 23, 2007 at 12:26:52PM -0800, Stephen Hemminger wrote:
> > 
> > Why does write cause an autobind? One would think that on a
> > SOCK_STREAM socket, the write should just fail with ENOTCONN
> 
> The autobind is occuring in generic code, i.e., inet_sendmsg().
> It will subsequently fail because the socket is not connected.

This is one of those situations where the -ENOTCONN might be
preferable, but we are not helping application writers one
iota because the bazillion existing kernels running out there
have the old behavior so app writers have to code for it
anyways.

So I think we should just leave things as they are.

If you read the language Richard Stevens uses when describing
both the usage and implementation of getsockname and
getpeername in BSD, he makes it very clear exactly what these
two interfaces are intended to be used for.

They are to be invoked in situations where the application
has no reason to know what the socket is bound to locally
or remotely, and there are two real cases:

1) determining the result of an auto-bind
2) finding the remote address/port of a socket obtained
   via a fork/exec

I'm sure there are some other minimally different variants,
but those are the two main cases.

This makes it doubly clear that uses such as the one in libnss-ldap
were totally unintended, and should be avoided since every single
OS behaves differently in this case. :-)
