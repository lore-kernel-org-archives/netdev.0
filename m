From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH net-next 1/9] openvswitch: Scrub packet in
 ovs_vport_receive()
Date: Fri, 31 Jul 2015 16:34:54 +0200
Message-ID: <1438353294.20479.7.camel@redhat.com>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
	 <1438279963-29563-2-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	jpettit@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	jesse@nicira.com, fwestpha@redhat.com, tgraf@noironetworks.com
To: Joe Stringer <joestringer@nicira.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438279963-29563-2-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-07-30 at 11:12 -0700, Joe Stringer wrote:
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
>  net/openvswitch/vport.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
> index d14f594..baa018f 100644
> --- a/net/openvswitch/vport.c
> +++ b/net/openvswitch/vport.c
> @@ -475,6 +475,9 @@ void ovs_vport_receive(struct vport *vport, struct 
> sk_buff *skb,
>  	struct sw_flow_key key;
>  	int error;
>  
> +	if (!skb->sk || (sock_net(skb->sk) != read_pnet(&vport->dp
> ->net)))
> +		skb_scrub_packet(skb, true);
> +
>  	stats = this_cpu_ptr(vport->percpu_stats);
>  	u64_stats_update_begin(&stats->syncp);
>  	stats->rx_packets++;

In general, this shouldn't be necessary as the packet should already be
scrubbed before they arrive here.

Could you maybe add a WARN_ON and check how those skbs with conntrack
data traverse the stack? I also didn't understand why make it dependent
on the socket.

Thanks,
Hannes
