From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC] datapath: offload hooks
Date: Thu, 9 Oct 2014 08:51:00 +0900
Message-ID: <20141008235056.GB31219@vergenet.net>
References: <1412728851-32534-1-git-send-email-simon.horman@netronome.com>
 <20141007215036.65f1d439@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, Jiri Pirko <jiri@resnulli.us>,
	Thomas Graf <tgraf@suug.ch>,
	John Fastabend <john.r.fastabend@intel.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Alexi Starovoitov <alexei.starovoitov@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Bert van Leeuwen <bert.vanleeuwen@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:59437 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbaJHXvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 19:51:17 -0400
Received: by mail-ig0-f182.google.com with SMTP id hn15so946289igb.3
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2014 16:51:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20141007215036.65f1d439@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2014 at 09:50:36PM -0700, Stephen Hemminger wrote:
> On Wed,  8 Oct 2014 09:40:51 +0900
> Simon Horman <simon.horman@netronome.com> wrote:
> 
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
> > +}
> 
> For security, you should mark any ops type table const, so an
> attacker can't find a home to poke their favorite routine into.

Thanks, I'll get that fixed.
