From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH/RFC] datapath: offload hooks
Date: Tue, 7 Oct 2014 21:50:36 -0700
Message-ID: <20141007215036.65f1d439@urahara>
References: <1412728851-32534-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
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
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:41262 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754539AbaJHEuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 00:50:54 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so6167844pdb.7
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 21:50:54 -0700 (PDT)
In-Reply-To: <1412728851-32534-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  8 Oct 2014 09:40:51 +0900
Simon Horman <simon.horman@netronome.com> wrote:

> +struct ovs_offload_ops {
> +	/* Flow offload functions  */
> +	/* Called when a flow entry is added to the flow table */
> +	void (*flow_new)(struct sw_flow *);
> +	/* Called when a flow entry is modified */
> +	void (*flow_set)(struct sw_flow *);
> +	/* Called when a flow entry is removed from the flow table */
> +	void (*flow_del)(struct sw_flow *);
> +	/* Called when flow stats are queried */
> +	void (*flow_stats_get)(const struct sw_flow *, struct ovs_flow_stats *,
> +			      unsigned long *used, __be16 *tcp_flags);
> +	/* Called when flow stats are removed */
> +	void (*flow_stats_clear)(struct sw_flow *);
> +
> +	/* Port offload functions  */
> +	/* Called when a vport is added to the datapath */
> +	void (*vport_new)(struct sk_buff *, struct vport *,
> +			  struct vport_parms *);
> +	/* Called when a vport is modified */
> +	void (*vport_set)(struct sk_buff *, struct vport *);
> +	/* Called when a vport is removed from the datapath */
> +	void (*vport_del)(struct sk_buff *, struct vport *);
> +	/* Called when vport stats are queried */
> +	void (*vport_stats_get)(struct vport *, struct ovs_vport_stats *);
> +	/* Called when vport stats are set */
> +	void (*vport_stats_set)(struct vport *, struct ovs_vport_stats *);
> +
> +	/* Datapath offload functions  */
> +	/* Called when the datapath is created */
> +	void (*dp_new)(struct datapath *);
> +	/* Called when the datapath is modified */
> +	void (*dp_set)(struct datapath *);
> +	/* Called when the datapath is removed */
> +	void (*dp_del)(struct datapath *);
> +	/* Called when the datapath stats are queried */
> +	void (*dp_stats_get)(struct datapath *, struct ovs_dp_stats *);
> +}

For security, you should mark any ops type table const, so an
attacker can't find a home to poke their favorite routine into.
