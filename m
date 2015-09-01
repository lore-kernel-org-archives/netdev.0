From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Make table id type u32
Date: Tue, 1 Sep 2015 12:25:58 -0600
Message-ID: <55E5EDB6.9050801@cumulusnetworks.com>
References: <1441131487-29367-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36451 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbbIAS0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 14:26:00 -0400
Received: by igcrk20 with SMTP id rk20so7722593igc.1
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 11:25:59 -0700 (PDT)
Received: from [192.168.1.182] (c-174-51-80-140.hsd1.co.comcast.net. [174.51.80.140])
        by smtp.googlemail.com with ESMTPSA id g85sm16732099iod.32.2015.09.01.11.25.58
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 11:25:59 -0700 (PDT)
In-Reply-To: <1441131487-29367-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

for net-next. Forgot to add to subject line. (Thanks, Roopa, for the 
reminder.)

On 9/1/15 12:18 PM, David Ahern wrote:
> A number of VRF patches used 'int' for table id. It should be u32 to be
> consistent with the rest of the stack.
>
> Fixes:
> 4e3c89920cd3a ("net: Introduce VRF related flags and helpers")
> 15be405eb2ea9 ("net: Add inet_addr lookup by table")
> 30bbaa1950055 ("net: Fix up inet_addr_type checks")
> 021dd3b8a142d ("net: Add routes to the table associated with the device")
> dc028da54ed35 ("inet: Move VRF table lookup to inlined function")
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>   include/net/route.h      |  2 +-
>   include/net/vrf.h        | 24 ++++++++++++------------
>   net/ipv4/af_inet.c       |  2 +-
>   net/ipv4/fib_frontend.c  | 10 +++++-----
>   net/ipv4/fib_semantics.c |  2 +-
>   5 files changed, 20 insertions(+), 20 deletions(-)
>
> diff --git a/include/net/route.h b/include/net/route.h
> index 395d79bb556c..cc61cb95f059 100644
> --- a/include/net/route.h
> +++ b/include/net/route.h
> @@ -188,7 +188,7 @@ void ipv4_sk_redirect(struct sk_buff *skb, struct sock *sk);
>   void ip_rt_send_redirect(struct sk_buff *skb);
>
>   unsigned int inet_addr_type(struct net *net, __be32 addr);
> -unsigned int inet_addr_type_table(struct net *net, __be32 addr, int tb_id);
> +unsigned int inet_addr_type_table(struct net *net, __be32 addr, u32 tb_id);
>   unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
>   				__be32 addr);
>   unsigned int inet_addr_type_dev_table(struct net *net,
> diff --git a/include/net/vrf.h b/include/net/vrf.h
> index 5bfb16237fd7..593e6094ddd4 100644
> --- a/include/net/vrf.h
> +++ b/include/net/vrf.h
> @@ -66,9 +66,9 @@ static inline int vrf_master_ifindex(const struct net_device *dev)
>   }
>
>   /* called with rcu_read_lock */
> -static inline int vrf_dev_table_rcu(const struct net_device *dev)
> +static inline u32 vrf_dev_table_rcu(const struct net_device *dev)
>   {
> -	int tb_id = 0;
> +	u32 tb_id = 0;
>
>   	if (dev) {
>   		struct net_vrf_dev *vrf_ptr;
> @@ -80,9 +80,9 @@ static inline int vrf_dev_table_rcu(const struct net_device *dev)
>   	return tb_id;
>   }
>
> -static inline int vrf_dev_table(const struct net_device *dev)
> +static inline u32 vrf_dev_table(const struct net_device *dev)
>   {
> -	int tb_id;
> +	u32 tb_id;
>
>   	rcu_read_lock();
>   	tb_id = vrf_dev_table_rcu(dev);
> @@ -91,10 +91,10 @@ static inline int vrf_dev_table(const struct net_device *dev)
>   	return tb_id;
>   }
>
> -static inline int vrf_dev_table_ifindex(struct net *net, int ifindex)
> +static inline u32 vrf_dev_table_ifindex(struct net *net, int ifindex)
>   {
>   	struct net_device *dev;
> -	int tb_id = 0;
> +	u32 tb_id = 0;
>
>   	if (!ifindex)
>   		return 0;
> @@ -111,9 +111,9 @@ static inline int vrf_dev_table_ifindex(struct net *net, int ifindex)
>   }
>
>   /* called with rtnl */
> -static inline int vrf_dev_table_rtnl(const struct net_device *dev)
> +static inline u32 vrf_dev_table_rtnl(const struct net_device *dev)
>   {
> -	int tb_id = 0;
> +	u32 tb_id = 0;
>
>   	if (dev) {
>   		struct net_vrf_dev *vrf_ptr;
> @@ -149,22 +149,22 @@ static inline int vrf_master_ifindex(const struct net_device *dev)
>   	return 0;
>   }
>
> -static inline int vrf_dev_table_rcu(const struct net_device *dev)
> +static inline u32 vrf_dev_table_rcu(const struct net_device *dev)
>   {
>   	return 0;
>   }
>
> -static inline int vrf_dev_table(const struct net_device *dev)
> +static inline u32 vrf_dev_table(const struct net_device *dev)
>   {
>   	return 0;
>   }
>
> -static inline int vrf_dev_table_ifindex(struct net *net, int ifindex)
> +static inline u32 vrf_dev_table_ifindex(struct net *net, int ifindex)
>   {
>   	return 0;
>   }
>
> -static inline int vrf_dev_table_rtnl(const struct net_device *dev)
> +static inline u32 vrf_dev_table_rtnl(const struct net_device *dev)
>   {
>   	return 0;
>   }
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 675e88cac2b4..8b9b7d77a9bf 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -428,7 +428,7 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>   	struct net *net = sock_net(sk);
>   	unsigned short snum;
>   	int chk_addr_ret;
> -	int tb_id = RT_TABLE_LOCAL;
> +	u32 tb_id = RT_TABLE_LOCAL;
>   	int err;
>
>   	/* If the socket has its own bind function then use it. (RAW) */
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 7fa277176c33..818b96a9b3c2 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -212,7 +212,7 @@ void fib_flush_external(struct net *net)
>    */
>   static inline unsigned int __inet_dev_addr_type(struct net *net,
>   						const struct net_device *dev,
> -						__be32 addr, int tb_id)
> +						__be32 addr, u32 tb_id)
>   {
>   	struct flowi4		fl4 = { .daddr = addr };
>   	struct fib_result	res;
> @@ -239,7 +239,7 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
>   	return ret;
>   }
>
> -unsigned int inet_addr_type_table(struct net *net, __be32 addr, int tb_id)
> +unsigned int inet_addr_type_table(struct net *net, __be32 addr, u32 tb_id)
>   {
>   	return __inet_dev_addr_type(net, NULL, addr, tb_id);
>   }
> @@ -254,7 +254,7 @@ EXPORT_SYMBOL(inet_addr_type);
>   unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
>   				__be32 addr)
>   {
> -	int rt_table = vrf_dev_table(dev) ? : RT_TABLE_LOCAL;
> +	u32 rt_table = vrf_dev_table(dev) ? : RT_TABLE_LOCAL;
>
>   	return __inet_dev_addr_type(net, dev, addr, rt_table);
>   }
> @@ -267,7 +267,7 @@ unsigned int inet_addr_type_dev_table(struct net *net,
>   				      const struct net_device *dev,
>   				      __be32 addr)
>   {
> -	int rt_table = vrf_dev_table(dev) ? : RT_TABLE_LOCAL;
> +	u32 rt_table = vrf_dev_table(dev) ? : RT_TABLE_LOCAL;
>
>   	return __inet_dev_addr_type(net, NULL, addr, rt_table);
>   }
> @@ -800,7 +800,7 @@ static int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
>   static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifaddr *ifa)
>   {
>   	struct net *net = dev_net(ifa->ifa_dev->dev);
> -	int tb_id = vrf_dev_table_rtnl(ifa->ifa_dev->dev);
> +	u32 tb_id = vrf_dev_table_rtnl(ifa->ifa_dev->dev);
>   	struct fib_table *tb;
>   	struct fib_config cfg = {
>   		.fc_protocol = RTPROT_KERNEL,
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index 1b2d01170a4d..fcb34791844c 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -863,7 +863,7 @@ static bool fib_valid_prefsrc(struct fib_config *cfg, __be32 fib_prefsrc)
>   {
>   	if (cfg->fc_type != RTN_LOCAL || !cfg->fc_dst ||
>   	    fib_prefsrc != cfg->fc_dst) {
> -		int tb_id = cfg->fc_table;
> +		u32 tb_id = cfg->fc_table;
>
>   		if (tb_id == RT_TABLE_MAIN)
>   			tb_id = RT_TABLE_LOCAL;
>
