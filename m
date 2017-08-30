From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v6 3/3] openvswitch: enable NSH support
Date: Wed, 30 Aug 2017 11:53:27 +0200
Message-ID: <87wp5l7560.fsf@stressinduktion.org>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
        <1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jbenc@redhat.com,
        e@erig.me, blp@ovn.org, jan.scheurich@ericsson.com
To: Yi Yang <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:53477 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751242AbdH3Jxb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 05:53:31 -0400
In-Reply-To: <1503670805-31051-4-git-send-email-yi.y.yang@intel.com> (Yi
        Yang's message of "Fri, 25 Aug 2017 22:20:05 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Yi Yang <yi.y.yang@intel.com> writes:

[...]

> +struct ovs_key_nsh {
> +	u8 flags;
> +	u8 ttl;
> +	u8 mdtype;
> +	u8 np;
> +	__be32 path_hdr;
> +	__be32 context[NSH_MD1_CONTEXT_SIZE];
> +};
> +
>  struct sw_flow_key {
>  	u8 tun_opts[IP_TUNNEL_OPTS_MAX];
>  	u8 tun_opts_len;
> @@ -144,6 +154,7 @@ struct sw_flow_key {
>  			};
>  		} ipv6;
>  	};
> +	struct ovs_key_nsh nsh;         /* network service header */
>  	struct {
>  		/* Connection tracking fields not packed above. */
>  		struct {

Does it makes sense to keep the context headers as part of the flow?
What is the reasoning behind it? With mdtype 2 headers this might either
not work very well or will increase sw_flow_key size causing slowdowns
for all protocols.

[...]
