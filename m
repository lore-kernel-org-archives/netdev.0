From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 13/27] bridge: use __vlan_hwaccel helpers
Date: Tue, 13 Dec 2016 15:59:46 +0300
Message-ID: <f5078470-0fc0-cfcd-36df-3ebb380b547a@cogentembedded.com>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
 <e6e09a2f745a652382ac7859770ec16c75d8e149.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "Pablo Neira Ayuso (supporter:NETFILTER ({IP ,IP6,ARP,EB,NF}TABLES))"
        <pablo@netfilter.org>,
        "Patrick McHardy (supporter:NETFILTER ({IP,IP6,ARP ,EB,NF}TABLES))"
        <kaber@trash.net>,
        "Jozsef Kadlecsik (supporter:NETFILTER ({IP,IP6,ARP,EB,NF}TABLES))"
        <kadlec@blackhole.kfki.hu>,
        "Stephen Hemminger (maintainer:ETHERNET BRIDGE)"
        <stephen@networkplumber.org>,
        "open list:NETFILTER ({IP,IP6,ARP,EB ,NF}TABLES)"
        <netfilter-devel@vger.kernel.org>,
        "moderated list:ETHERNET BRIDGE" <bridge@lists.linux-foundation.org>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
        netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <e6e09a2f745a652382ac7859770ec16c75d8e149.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 12/13/2016 3:12 AM, Michał Mirosław wrote:

> This removes assumption than vlan_tci != 0 when tag is present.
>
> Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
> ---
>  net/bridge/br_netfilter_hooks.c | 14 ++++++++------
>  net/bridge/br_private.h         |  2 +-
>  net/bridge/br_vlan.c            |  6 +++---
>  3 files changed, 12 insertions(+), 10 deletions(-)
>
> diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
> index b12501a..2cc0747 100644
> --- a/net/bridge/br_netfilter_hooks.c
> +++ b/net/bridge/br_netfilter_hooks.c
[...]
> @@ -749,8 +747,12 @@ static int br_nf_dev_queue_xmit(struct net *net, struct sock *sk, struct sk_buff
>
>  		data = this_cpu_ptr(&brnf_frag_data_storage);
>
> -		data->vlan_tci = skb->vlan_tci;
> -		data->vlan_proto = skb->vlan_proto;
> +		if (skb_vlan_tag_present(skb)) {
> +			data->vlan_tci = skb->vlan_tci;
> +			data->vlan_proto = skb->vlan_proto;
> +		} else
> +			data->vlan_proto = 0;

    CodingStyle: should use {} in all branches of *if* if at least one branch 
has {}.

[...]
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index b6de4f4..ef94664 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c

> @@ -444,8 +444,8 @@ static bool __allowed_ingress(const struct net_bridge *br,
>  			__vlan_hwaccel_put_tag(skb, br->vlan_proto, pvid);
>  		else
>  			/* Priority-tagged Frame.
> -			 * At this point, We know that skb->vlan_tci had
> -			 * VLAN_TAG_PRESENT bit and its VID field was 0x000.
> +			 * At this point, We know that skb->vlan_tci VID

    s/We/we/.

> +			 * field was 0x000.

    Simply 0, maybe?

[...]

MBR, Sergei

