From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 2/2] multicast: Extend ip address command
 to enable multicast group join/leave on IP level.
Date: Sat, 21 Feb 2015 19:04:21 -0500 (EST)
Message-ID: <20150221.190421.2134726339184440278.davem@davemloft.net>
References: <1424222346-12736-1-git-send-email-challa@noironetworks.com>
	<1424222346-12736-2-git-send-email-challa@noironetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: challa@noironetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35099 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745AbbBVAEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 19:04:25 -0500
In-Reply-To: <1424222346-12736-2-git-send-email-challa@noironetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Madhu Challa <challa@noironetworks.com>
Date: Tue, 17 Feb 2015 17:19:06 -0800

>     Joining multicast group on ethernet level via "ip maddr" command would
>     not work if we have an Ethernet switch that does igmp snooping since
>     the switch would not replicate multicast packets on ports that did not
>     have IGMP reports for the multicast addresses.
> 
>     Linux vxlan interfaces created via "ip link add vxlan" have the group option
>     that enables then to do the required join.
> 
>     By extending ip address command with option "autojoin" we can get similar
>     functionality for openvswitch vxlan interfaces as well as other tunneling
>     mechanisms that need to receive multicast traffic. The kernel code is
>     structured similar to how the vxlan driver does a group join / leave.
> 
>     example:
>     ip address add 224.1.1.10/24 dev eth5 autojoin
>     ip address del 224.1.1.10/24 dev eth5
> 
>     v2 address review comments from Eric Dumazet.
> 
>     This patch applies on top of
>     [PATCH net-next] igmp: add __ip_mc_{join|leave}_group()
>     by Eric Dumazet. and
>     igmp v6: add __ipv6_sock_mc_join and __ipv6_sock_mc_drop
> 
>     remove the work queue and call the __ip_mc_{join|leave}_group
>     and the ipv6 variant __ipv6_sock_mc_{join|drop}
> 
>     Signed-off-by: Madhu Challa <challa@noironetworks.com>

Please do not add this indentation to every line in your commit message.

Also, you should provide a "[PATCH net-next 0/2] xxx" posting that explains
at a high level what your patch series is doing, and why.

> +static int ip_mc_config(struct sock *sk, bool join, __be32 saddr, int ifindex)
> +{
> +	int ret;
> +	struct ip_mreqn mreq = {
> +		.imr_multiaddr.s_addr = saddr,
> +		.imr_ifindex = ifindex,
> +	};

Please order local variable declarations in "reverse christmas tree"
ordering, meaning longer lines before shorter ones.

> @@ -2740,6 +2740,8 @@ static const struct file_operations igmp_mcf_seq_fops = {
>  static int __net_init igmp_net_init(struct net *net)
>  {
>  	struct proc_dir_entry *pde;
> +	int err;
> +	struct socket *sock = NULL;
>  
>  	pde = proc_create("igmp", S_IRUGO, net->proc_net, &igmp_mc_seq_fops);
>  	if (!pde)

Likewise.
