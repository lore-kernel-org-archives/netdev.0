From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [PATCH v4 net-next] MPLS: Use mpls_features to
 activate software MPLS GSO segmentation
Date: Tue, 3 Jun 2014 13:49:48 +0900
Message-ID: <20140603044948.GA23151@verge.net.au>
References: <20140603043047.GB22191@verge.net.au>
 <20140603044611.C2B0970BA7@kuma.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
 eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140603044611.C2B0970BA7-0CV7wKnmZOB82hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Tue, Jun 03, 2014 at 01:46:11PM +0900, YAMAMOTO Takashi wrote:
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 0355ca5..7c063ac 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -2498,13 +2498,42 @@ static int dev_gso_segment(struct sk_buff *skb, netdev_features_t features)
> >  	return 0;
> >  }
> >  
> > +/* If MPLS offload request, verify we are testing hardware MPLS features
> > + * instead of standard features for the netdev.
> > + */
> > +#ifdef CONFIG_NET_MPLS_GSO
> > +static netdev_features_t net_mpls_features(struct sk_buff *skb,
> > +					   netdev_features_t features,
> > +					   __be16 type)
> > +{
> > +	int tmp;
> 
> this variable seems no longer used.

Thanks, I will remove it.

> > +
> > +	if (unlikely(type == htons(ETH_P_MPLS_UC) ||
> > +		     type == htons(ETH_P_MPLS_MC)))
> 
> why unlikely?

Because packets are not likely to be MPLS (IMHO).
I'm happy to remove the unlikely() if you like.

> 
> otherwise,
> Acked-by: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
> 
> YAMAMOTO Takashi
> 
