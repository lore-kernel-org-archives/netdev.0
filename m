From: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Subject: Re: [PATCH/RFC] datapath: offload hooks
Date: Thu, 9 Oct 2014 09:07:10 +0900
Message-ID: <20141009000707.GA9339@vergenet.net>
References: <1412728851-32534-1-git-send-email-simon.horman@netronome.com>
 <20141007215521.493233d2@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
 John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 Bert van Leeuwen <bert.vanleeuwen-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>,
 Scott Feldman <sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20141007215521.493233d2@urahara>
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

On Tue, Oct 07, 2014 at 09:55:21PM -0700, Stephen Hemminger wrote:
> On Wed,  8 Oct 2014 09:40:51 +0900
> Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org> wrote:
> 
> > +
> > +struct ovs_offload_ops {
> > +	/* Flow offload functions  */
> > +	/* Called when a flow entry is added to the flow table */
> > +	void (*flow_new)(struct sw_flow *);
> > +	/* Called when a flow entry is modified */
> > +	void (*flow_set)(struct sw_flow *);
> > +	/* Called when a flow entry is removed from the flow table */
> > +	void (*flow_del)(struct sw_flow *);
> > +	/* Called when flow stats are queried */
> > +	void (*flow_stats_get)(const struct sw_flow *, struct ovs_flow_stats *,
> > +			      unsigned long *used, __be16 *tcp_flags);
> > +	/* Called when flow stats are removed */
> > +	void (*flow_stats_clear)(struct sw_flow *);
> > +
> > +	/* Port offload functions  */
> > +	/* Called when a vport is added to the datapath */
> > +	void (*vport_new)(struct sk_buff *, struct vport *,
> > +			  struct vport_parms *);
> > +	/* Called when a vport is modified */
> > +	void (*vport_set)(struct sk_buff *, struct vport *);
> > +	/* Called when a vport is removed from the datapath */
> > +	void (*vport_del)(struct sk_buff *, struct vport *);
> > +	/* Called when vport stats are queried */
> > +	void (*vport_stats_get)(struct vport *, struct ovs_vport_stats *);
> > +	/* Called when vport stats are set */
> > +	void (*vport_stats_set)(struct vport *, struct ovs_vport_stats *);
> > +
> > +	/* Datapath offload functions  */
> > +	/* Called when the datapath is created */
> > +	void (*dp_new)(struct datapath *);
> > +	/* Called when the datapath is modified */
> > +	void (*dp_set)(struct datapath *);
> > +	/* Called when the datapath is removed */
> > +	void (*dp_del)(struct datapath *);
> > +	/* Called when the datapath stats are queried */
> > +	void (*dp_stats_get)(struct datapath *, struct ovs_dp_stats *);
> > +};
> 
> What about using netlink and netlink notifiers for event type stuff?
> Much easier to extend than all the _ops stuff and you can provide
> hook for people that want to do it in user space.

Hi Stephen,

thanks, that is not an avenue that I had previously considered,
though on that point I'm not speaking for others at Netronome.

I wonder if you could expand a little on which of the above you
consider event type stuff. From my point of view the hooks seem
to fall into two categories:

1. Hooks that are called to obtain information about the datapath.
   That is the *stats* hooks.
2. Hooks that are called when reconfiguration occurs.
   That is the non *stats* hooks.

It seems to me that both categories are typically driven by requests from
user-space.
