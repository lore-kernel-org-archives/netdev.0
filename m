From: Thomas Graf <tgraf@suug.ch>
Subject: Re: request_module while holding rtnl semaphore
Date: Wed, 10 Nov 2004 12:56:45 +0100
Message-ID: <20041110115645.GN31969@postel.suug.ch>
References: <E1CQDcP-0003ff-00@gondolin.me.apana.org.au> <20041109161126.376f755c.davem@davemloft.net> <20041110010113.GJ31969@postel.suug.ch> <41916A91.3080107@trash.net> <20041110012251.GK31969@postel.suug.ch> <41916F0B.5010809@trash.net> <20041110013941.GL31969@postel.suug.ch> <20041110014125.GA7302@gondor.apana.org.au> <20041110113236.GM31969@postel.suug.ch> <20041110114209.GA11336@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20041110114209.GA11336@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <20041110114209.GA11336@gondor.apana.org.au> 2004-11-10 22:42
> On Wed, Nov 10, 2004 at 12:32:36PM +0100, Thomas Graf wrote:
> > 
> > Agreed. I'm used to huge filter configurations up to 100 MiB per
> > netlink message and therefore I do care whether such as message is
> 
> 100MiB!? How did you manage to stuff that into one linear skb?

It's splitted over multiple netlink messages. My classifier
keeps appending the messages in a hash table referenced by the
sequence number until a flag is set marking the end and then
processes the whole message. It's ugly but it works and is atomic
without locking over multiple netlink messages.
