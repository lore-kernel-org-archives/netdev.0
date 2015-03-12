From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: Re: [PATCH RFC 2/4] aio: prefer aio_op op over iter_op
Date: Thu, 12 Mar 2015 07:00:59 -0700
Message-ID: <55019C1B.6090909@intel.com>
References: <20150311224607.23777.2181.stgit@tstruk-mobl1> <20150311224618.23777.38330.stgit@tstruk-mobl1> <20150312064825.GL29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-aio@kvack.org,
 herbert@gondor.apana.org.au, netdev@vger.kernel.org,
 ying.xue@windriver.com, bcrl@kvack.org, linux-fsdevel@vger.kernel.org,
 hch@lst.de, linux-crypto@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <owner-linux-aio@kvack.org>
In-Reply-To: <20150312064825.GL29656@ZenIV.linux.org.uk>
Sender: owner-linux-aio@kvack.org
List-Id: netdev.vger.kernel.org

On 03/11/2015 11:48 PM, Al Viro wrote:
>> AIO interface should prefer AIO operations over iter_op
> What the devil for?  read_iter and write_iter *ARE* aio operations, as much
> as soon to be removed aio_read and aio_write.  And yes, those are going to
> be removed very soon.

That's fine. When those will get removed, then as part of the cleanup we can 
merge sock_read_iter() with sock_aio_read() and sock_write_iter()
with sock_aio_write() and call sock_recvmsg()/sock_sendmsg() or 
sock->ops->aio_recvmsg()/sock->ops->aio_sendmsg based on if (is_sync_kiocb(iocb))

> 
> Note that ->read_iter() and ->write_iter() are getting iocb pointer passed
> to them.  It's just that socket instances are not passing it along to
> ->sendmsg/->recvmsg anymore.

and that's the main reason why I have added the sock_aio_read() and sock_aio_write()
I didn't want to mess with the sock_read_iter() and sock_write_iter() for now.

> 
> And why, in name of everything unholy, do your methods get redundant
> total_len argument?  It's iov_iter_count(&msg->msg_iter) (and in iov_iter-net
> I have an inline helper doing that - enough places open-coding that thing).
> If nothing else, ->sendmsg() and ->recvmsg() would benefit from removing
> that argument as well.  I have patches doing that, but iocb removal conflicts
> with them and they need to be rebased to current net/master...

You are right, it's not needed at all. I took the signatures from sendmsg() and
recvmsg() and just added iocb. I will remove them in v2 if you want, or you can
add it to your patches.

--
To unsubscribe, send a message with 'unsubscribe linux-aio' in
the body to majordomo@kvack.org.  For more info on Linux AIO,
see: http://www.kvack.org/aio/
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
