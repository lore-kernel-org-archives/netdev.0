From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH net-next 5/9] openvswitch: Add conntrack action
Date: Fri, 31 Jul 2015 17:26:02 +0200
Message-ID: <1438356362.20479.16.camel@redhat.com>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
	 <1438279963-29563-6-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	jpettit@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	jesse@nicira.com, fwestpha@redhat.com, tgraf@noironetworks.com
To: Joe Stringer <joestringer@nicira.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438279963-29563-6-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-07-30 at 11:12 -0700, Joe Stringer wrote:
> +static void do_output(struct datapath *dp, struct sk_buff *skb, int
> out_port,
> +		      struct sw_flow_key *key)
>  {
>  	struct vport *vport = ovs_vport_rcu(dp, out_port);
>  
> -	if (likely(vport))
> -		ovs_vport_send(vport, skb);
> -	else
> +	if (likely(vport)) {
> +		unsigned int mru = OVS_CB(skb)->mru;
> +		struct dst_entry *orig_dst = dst_clone(skb_dst(skb));

I think you forgot to remove this?

Bye,
Hannes
