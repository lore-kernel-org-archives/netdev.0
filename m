From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/9] net: openvswitch: use this_cpu_ptr
	per-cpu helper
Date: Fri, 2 Nov 2012 17:46:02 +0000
Message-ID: <0000013ac23ac528-19a0dd1b-3144-45df-9d6e-471999d6ae31-000000@email.amazonses.com>
References: <5093EE59.8010609@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel-Maillist <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Shan Wei <shanwei88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <5093EE59.8010609-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 3 Nov 2012, Shan Wei wrote:

> +++ b/net/openvswitch/datapath.c
> @@ -208,7 +208,7 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
>  	int error;
>  	int key_len;
>
> -	stats = per_cpu_ptr(dp->stats_percpu, smp_processor_id());
> +	stats = this_cpu_ptr(dp->stats_percpu);
>
>  	/* Extract flow from 'skb' into 'key'. */
>  	error = ovs_flow_extract(skb, p->port_no, &key, &key_len);
> @@ -282,7 +282,7 @@ int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
>  	return 0;
>
>  err:
> -	stats = per_cpu_ptr(dp->stats_percpu, smp_processor_id());
> +	stats = this_cpu_ptr(dp->stats_percpu);
>
>  	u64_stats_update_begin(&stats->sync);
>  	stats->n_lost++;
> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
> index 03779e8..70af0be 100644
> --- a/net/openvswitch/vport.c
> +++ b/net/openvswitch/vport.c
> @@ -333,8 +333,7 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb)
>  {
>  	struct vport_percpu_stats *stats;
>
> -	stats = per_cpu_ptr(vport->percpu_stats, smp_processor_id());
> -
> +	stats = this_cpu_ptr(vport->percpu_stats);
>  	u64_stats_update_begin(&stats->sync);
>  	stats->rx_packets++;
>  	stats->rx_bytes += skb->len;
> @@ -359,7 +358,7 @@ int ovs_vport_send(struct vport *vport, struct sk_buff *skb)
>  	if (likely(sent)) {
>  		struct vport_percpu_stats *stats;
>
> -		stats = per_cpu_ptr(vport->percpu_stats, smp_processor_id());
> +		stats = this_cpu_ptr(vport->percpu_stats);
>
>  		u64_stats_update_begin(&stats->sync);
>  		stats->tx_packets++;

Use this_cpu_inc(vport->percpu_stats->packets) here?
