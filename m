From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Where exactly will arch_fast_hash be used
Date: Thu, 4 Dec 2014 15:26:37 +0000
Message-ID: <20141204152637.GA32140@casper.infradead.org>
References: <20141204081147.GA19030@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Theodore Ts'o <tytso@mit.edu>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141204081147.GA19030@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/04/14 at 04:11pm, Herbert Xu wrote:
> Hi:
> 
> While working on rhashtable it came to me that this whole concept
> of arch_fast_hash is flawed.  CRCs are linear functions so it's
> fairly easy for an attacker to identify collisions or at least
> eliminate a large amount of search space (e.g., controlling the
> last bit of the hash result is almost trivial, even when you add
> a random seed).
> 
> So what exactly are we going to use arch_fast_hash for? Presumably
> it's places where security is never goint to be an issue, right?
> 
> Even if security wasn't an issue, straight CRC32 has really poor
> lower-order bit distribution, which makes it a terrible choice for
> a hash table that simply uses the lower-order bits.

As Daniel pointed out, this work originated for the OVS edge use
case where security is of less concern and the rehashing is
sufficient. Identifying collisions is less of interest as the user
space fall back provides a greater surface for an attack.
