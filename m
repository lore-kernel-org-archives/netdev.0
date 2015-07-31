From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 1/9] openvswitch: Scrub packet in ovs_vport_receive()
Date: Thu, 30 Jul 2015 20:43:23 -0700
Message-ID: <CALnjE+oXzYbOFHiji3CoDSjmS5Lai+rE12_ubAEjMbm6+KRj9Q@mail.gmail.com>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
	<1438279963-29563-2-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo@netfilter.org,
	Patrick McHardy <kaber@trash.net>,
	Justin Pettit <jpettit@nicira.com>,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>,
	Thomas Graf <tgraf@noironetworks.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438279963-29563-2-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 30, 2015 at 11:12 AM, Joe Stringer <joestringer@nicira.com> wrote:
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
>  net/openvswitch/vport.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
> index d14f594..baa018f 100644
> --- a/net/openvswitch/vport.c
> +++ b/net/openvswitch/vport.c
> @@ -475,6 +475,9 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
>         struct sw_flow_key key;
>         int error;
>
> +       if (!skb->sk || (sock_net(skb->sk) != read_pnet(&vport->dp->net)))
> +               skb_scrub_packet(skb, true);
> +
skb scrub drops dst which cause use-after-free bug for flow based
tunnel devices.


>         stats = this_cpu_ptr(vport->percpu_stats);
>         u64_stats_update_begin(&stats->syncp);
>         stats->rx_packets++;
> --
> 2.1.4
>
