From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Sun, 19 Sep 2004 22:00:13 +1000
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040919120013.GA5915@gondor.apana.org.au>
References: <412DF807.2040703@eurodev.net> <E1C90Da-0001V7-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <E1C90Da-0001V7-00@gondolin.me.apana.org.au>
List-Id: netdev.vger.kernel.org

On Sun, Sep 19, 2004 at 09:50:58PM +1000, Herbert Xu wrote:
> 
> Previously netlink requests had overhead comparable to that of an
> ioctl.  Now you've added two full context switches to it.  There's
> gotta be a better way to fix this dead-lock.

Worse still, previously if a netlink request blocked indefinitely it
only did that in the context of the calling process.  Now it'll
dead-lock the entire system because you're using the generic work
queue.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
