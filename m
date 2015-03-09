From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next] tipc: sparse: fix htons
	conversion warnings
Date: Mon, 9 Mar 2015 17:31:27 +0800
Message-ID: <54FD686F.9050604@windriver.com>
References: <1425892771-15120-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, laszlo.benedek@ericsson.com,
	tipc-discussion@lists.sourceforge.net
To: <erik.hugne@ericsson.com>, <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1425892771-15120-1-git-send-email-erik.hugne@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 03/09/2015 05:19 PM, erik.hugne@ericsson.com wrote:
> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> Commit d0f91938bede ("tipc: add ip/udp media type") introduced
> some new sparse warnings. Clean them up.
> 

It's better to add original sparse warning messages in commit header.

Regards,
Ying

> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> ---
>  net/tipc/udp_media.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
> index 0d10001..fc2fb11 100644
> --- a/net/tipc/udp_media.c
> +++ b/net/tipc/udp_media.c
> @@ -162,7 +162,7 @@ static int tipc_udp_send_msg(struct net *net, struct sk_buff *skb,
>  		err = -ENODEV;
>  		goto tx_error;
>  	}
> -	if (htons(dst->proto) == ETH_P_IP) {
> +	if (dst->proto == htons(ETH_P_IP)) {
>  		struct flowi4 fl = {
>  			.daddr = dst->ipv4.s_addr,
>  			.saddr = src->ipv4.s_addr,
> @@ -334,7 +334,7 @@ static int tipc_udp_enable(struct net *net, struct tipc_bearer *b,
>  	struct udp_media_addr *remote;
>  	struct udp_media_addr local = {0};
>  	struct udp_port_cfg udp_conf = {0};
> -	struct udp_tunnel_sock_cfg tuncfg = {0};
> +	struct udp_tunnel_sock_cfg tuncfg = {NULL};
>  
>  	ub = kzalloc(sizeof(*ub), GFP_ATOMIC);
>  	if (!ub)
> @@ -351,7 +351,7 @@ static int tipc_udp_enable(struct net *net, struct tipc_bearer *b,
>  	rcu_assign_pointer(b->media_ptr, ub);
>  	rcu_assign_pointer(ub->bearer, b);
>  	tipc_udp_media_addr_set(&b->addr, &local);
> -	if (htons(local.proto) == ETH_P_IP) {
> +	if (local.proto == htons(ETH_P_IP)) {
>  		struct net_device *dev;
>  
>  		dev = __ip_dev_find(net, local.ipv4.s_addr, false);
> @@ -366,7 +366,7 @@ static int tipc_udp_enable(struct net *net, struct tipc_bearer *b,
>  		b->mtu = dev->mtu - sizeof(struct iphdr)
>  			- sizeof(struct udphdr);
>  #if IS_ENABLED(CONFIG_IPV6)
> -	} else if (htons(local.proto) == ETH_P_IPV6) {
> +	} else if (local.proto == htons(ETH_P_IPV6)) {
>  		udp_conf.family = AF_INET6;
>  		udp_conf.use_udp6_tx_checksums = true;
>  		udp_conf.use_udp6_rx_checksums = true;
> 


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
