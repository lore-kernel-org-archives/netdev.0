From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Fri, 1 Apr 2005 12:28:02 -0800
Message-ID: <20050401122802.7c71afbc.davem@davemloft.net>
References: <42370997.6010302@cosmosbay.com>
	<20050315103253.590c8bfc.davem@davemloft.net>
	<42380EC6.60100@cosmosbay.com>
	<20050316140915.0f6b9528.davem@davemloft.net>
	<4239E00C.4080309@cosmosbay.com>
	<20050331221352.13695124.davem@davemloft.net>
	<424D5D34.4030800@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <424D5D34.4030800@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 01 Apr 2005 16:39:48 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> > If spinlock_t is a zero sized structure on UP, how can this save memory
> > on UP? :-)
> 
> Because I deleted the  __attribute__((__aligned__(8))) constraint on struct rt_hash_bucket.

Right.

> > Anyways, I think perhaps you should dynamically allocate this lock table.
> 
> Maybe I should make a static sizing, (replace the 256 constant by something based on MAX_CPUS) ?

Even for NR_CPUS, I think the table should be dynamically allocated.

It is a goal to eliminate all of these huge arrays in the static
kernel image, which has grown incredibly too much in recent times.
I work often to eliminate such things, let's not add new ones :-)
