From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NET] Add barriers for dst refcnt
Date: Sat, 5 Feb 2005 17:21:01 -0800
Message-ID: <20050205172101.7874e1dd.davem@davemloft.net>
References: <20050204073311.GA11716@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, anton@samba.org
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050204073311.GA11716@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 4 Feb 2005 18:33:11 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> In light of the recent discussion about sk_buff, I think we need
> the following patch for dst_entry.  This adds a memory barrier
> before dst_release drops the refcnt, and a read memory barrier
> before dst_destroy starts destroying the entry.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Good catch.

I "think" the dst_release() case is theoretical.  dst_release()
runs in a locked context for the thing referencing 'dst'.  Be it
the route hash, a socket, whatever.

BTW, looking at dst_release() call sites, xchg() might be another
primitive we need to watch out for memory barrier semantics of.
Since it returns a value, it would seem to need to be strictly
ordered wrt. other memory operations.  And sure enough, ppc64
has the memory barriers there.

Man, something else to audit on sparc64 and document in atomic_ops.txt
:-)

Anyways, Herbert's patch is correct and I'll apply it.  Thanks.
