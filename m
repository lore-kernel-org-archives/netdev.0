From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPCOMP] Use per-cpu buffers
Date: Thu, 9 Sep 2004 09:16:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909091652.490c7833.davem@davemloft.net>
References: <20040909122202.GA3170@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040909122202.GA3170@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Sep 2004 22:22:02 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> With per-cpu buffers this goes down to 300K per CPU.

That amount of space just for decompression state is
rediculious.

I seem to recall that the last time I looked at this
the reason the tables are so huge is that the zlib
we use in the kernel isn't configurable.  The table
configuration is compile time decided.

Yes, it's because of linux/zlib.h's cpp settings.

I guess it would be a lot of surgery to make this dynamic.

A second thought is that we may not be the only part
of the kernel interested in a per-cpu zlib scratch
buffer, no?
