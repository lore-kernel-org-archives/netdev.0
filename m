From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] no more rwlock_t inside tcp_ehash_bucket
Date: Tue, 15 Mar 2005 10:32:53 -0800
Message-ID: <20050315103253.590c8bfc.davem@davemloft.net>
References: <42370997.6010302@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <42370997.6010302@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Mar 2005 17:13:11 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:
 
> I suggest in this patch using an array of 256 rwlocks.
> 
> - Less memory used (or 2 x more entries in hash table if size >= (2^MAX_ORDER)*PAGE_SIZE)
> - less memory touched during read_lock()/read_unlock()
> - Better sharing of hash entries between cpus

I'm generally in support of this change, however 2 suggestions:

1) Please allocate the rwlock table dynamically.  You can put
   #ifdef CONFIG_SMP around this stuff if you wish so that
   we don't do silly things like allocate a zero sized table
   on non-SMP builds.

   Perhaps you might want to similarly abstract out the rwlock
   acquisition, "tcp_ehash_lock(unsigned int slot)" and
   "tcp_ehash_unlock(unsigned int slot)".  It's just an idea.

2) With dynamic allocation, you can consider perhaps dynamic sizing
   based upon a) the ehash size b) NR_CPUS or some combination of
   those two.
