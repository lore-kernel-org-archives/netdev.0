From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 2/2] nft_hash: define max_shift rhashtable parameter
Date: Tue, 24 Feb 2015 16:42:19 +0000
Message-ID: <20150224164219.GC21107@casper.infradead.org>
References: <1424794259-30241-1-git-send-email-johunt@akamai.com>
 <1424794259-30241-3-git-send-email-johunt@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: Josh Hunt <johunt@akamai.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1424794259-30241-3-git-send-email-johunt@akamai.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/24/15 at 11:10am, Josh Hunt wrote:
> You must define a max_shift parameter to rhashtable or else the table cannot
> grow. This sets max_shift for nft_hash to 24, which will allow the table to
> grow to 2^24 or 16 million buckets.
> 
> Signed-off-by: Josh Hunt <johunt@akamai.com>
> ---
>  net/netfilter/nft_hash.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
> index 61e6c40..839ed30 100644
> --- a/net/netfilter/nft_hash.c
> +++ b/net/netfilter/nft_hash.c
> @@ -23,6 +23,9 @@
>  /* We target a hash table size of 4, element hint is 75% of final size */
>  #define NFT_HASH_ELEMENT_HINT 3
>  
> +/* Set default of 2^24 buckets or 16 million entries */
> +#define NFT_HASH_MAX_ELEMENTS 24

Maybe this should be called .._MAX_BUCKETS instead, the table
itself does not have a upper nelements limit but will not grow
above 16M buckets as the comment states correctly already.

After this change:
Acked-by: Thomas Graf <tgraf@suug.ch>
