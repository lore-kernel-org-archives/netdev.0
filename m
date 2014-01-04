From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net PATCH] netfilter: only warn once on wrong seqadj usage
Date: Sat, 4 Jan 2014 13:16:48 +0000
Message-ID: <20140104131648.GA18176@macbook.localnet>
References: <20140104130944.28481.30891.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Flavio Leitner <fbl@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140104130944.28481.30891.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 04, 2014 at 02:10:43PM +0100, Jesper Dangaard Brouer wrote:
> Avoid potentially spamming the kernel log with WARN splash messages
> when catching wrong usage of seqadj, by simply using WARN_ONCE.
> 
> This is a followup to commit db12cf274353 (netfilter: WARN about
> wrong usage of sequence number adjustments)
> 
> Suggested-by: Flavio Leitner <fbl@redhat.com>
> Suggested-by: Daniel Borkmann <dborkman@redhat.com>
> Suggested-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
> Nitpick found by internal RedHat review process ;-)
> 
>  net/netfilter/nf_conntrack_seqadj.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
> index b2d38da..f6e2ae9 100644
> --- a/net/netfilter/nf_conntrack_seqadj.c
> +++ b/net/netfilter/nf_conntrack_seqadj.c
> @@ -37,7 +37,7 @@ int nf_ct_seqadj_set(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
>  		return 0;
>  
>  	if (unlikely(!seqadj)) {
> -		WARN(1, "Wrong seqadj usage, missing nfct_seqadj_ext_add()\n");
> +		WARN_ONCE(1, "Missing nfct_seqadj_ext_add() setup call\n");
>  		return 0;

I missed the patch that added the WARN. Since when do we add runtime checks
for API misuse instead of simply letting it crash?

