From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH RFC 2/4] aio: prefer aio_op op over iter_op
Date: Thu, 12 Mar 2015 06:48:25 +0000
Message-ID: <20150312064825.GL29656@ZenIV.linux.org.uk>
References: <20150311224607.23777.2181.stgit@tstruk-mobl1>
 <20150311224618.23777.38330.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-aio@kvack.org,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	ying.xue@windriver.com, bcrl@kvack.org,
	linux-fsdevel@vger.kernel.org, hch@lst.de,
	linux-crypto@vger.kernel.org
To: Tadeusz Struk <tadeusz.struk@intel.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150311224618.23777.38330.stgit@tstruk-mobl1>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 11, 2015 at 03:46:18PM -0700, Tadeusz Struk wrote:
> AIO interface should prefer AIO operations over iter_op

What the devil for?  read_iter and write_iter *ARE* aio operations, as much
as soon to be removed aio_read and aio_write.  And yes, those are going to
be removed very soon.

Note that ->read_iter() and ->write_iter() are getting iocb pointer passed
to them.  It's just that socket instances are not passing it along to
->sendmsg/->recvmsg anymore.

And why, in name of everything unholy, do your methods get redundant
total_len argument?  It's iov_iter_count(&msg->msg_iter) (and in iov_iter-net
I have an inline helper doing that - enough places open-coding that thing).
If nothing else, ->sendmsg() and ->recvmsg() would benefit from removing
that argument as well.  I have patches doing that, but iocb removal conflicts
with them and they need to be rebased to current net/master...
