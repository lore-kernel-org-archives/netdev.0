From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [PATCH v2 net-next repost] MPLS: Use mpls_features to
 activate software MPLS GSO segmentation
Date: Mon, 2 Jun 2014 09:08:00 +0900
Message-ID: <20140602000800.GD20022@verge.net.au>
References: <20140530053519.GA3444@verge.net.au>
 <20140530.154318.305349726927694948.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140530.154318.305349726927694948.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

On Fri, May 30, 2014 at 03:43:18PM -0700, David Miller wrote:
> From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
> Date: Fri, 30 May 2014 14:35:19 +0900
> 
> > If an MPLS packet requires segmentation then use mpls_features
> > to determine if the software implementation should be used.
> > 
> > As no driver advertises MPLS GSO segmentation this will always be
> > the case.
> > 
> > I had not noticed that this was necessary before as software MPLS GSO
> > segmentation was already being used in my test environment. I believe that
> > the reason for that is the skbs in question always had fragments and the
> > driver I used does not advertise NETIF_F_FRAGLIST (which seems to be the
> > case for most drivers). Thus software segmentation was activated by
> > skb_gso_ok().
> > 
> > Thanks to Jesse Gross for prompting me to investigate this.
> > 
> > Acked-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> > Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
> 
> Just requesting some stylistic changes:
> 
> > +/* If MPLS offload request, verify we are testing hardware MPLS features
> > + * instead of standard features for the netdev.
> > + */
> > +#ifdef CONFIG_NET_MPLS_GSO
> > +static inline netdev_features_t net_mpls_features(struct sk_buff *skb,
> > +	struct net_device *dev, netdev_features_t features)
> 
> Do not use inline in a foo.c file, let the compiler make the decision.
> 
> Also, line up the arguments on the second line correctly, they should
> start exactly at the first column after the openning parenthesis of
> the previous line.
> 
> > +static inline netdev_features_t net_mpls_features(struct sk_buff *skb,
> > +	struct net_device *dev, netdev_features_t features)
> > +{
> > +	return features;
> > +}
> 
> Similarly.

Thanks, I'll fix things up and repost.
