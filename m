From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Check connect address in NETLINK
Date: Wed, 30 Jun 2004 16:14:20 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040630121420.GA8183@ms2.inr.ac.ru>
References: <20040628231439.GA3021@gondor.apana.org.au> <20040629082252.GA26866@ms2.inr.ac.ru> <20040629084552.GA6202@gondor.apana.org.au> <20040629111433.GA28463@ms2.inr.ac.ru> <20040629111833.GA22880@gondor.apana.org.au> <20040630112751.GA31160@gondor.apana.org.au> <20040630120045.GA7973@ms2.inr.ac.ru> <20040630120828.GA31498@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20040630120828.GA31498@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> OK.  Can you give me a code path that allows sk_socket to be NULL
> at this point?

cpu 0:				cpu1 (or just preempted cpu)

sk = netlink_lookup(...);
				... closing sk
				netlink_release() clears sk_socket

use sk->sk_socket. Oops.

Alexey
