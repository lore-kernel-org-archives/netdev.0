From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/4] [NETLINK] introduce netlink_check_skb function
Date: Fri, 11 Feb 2005 04:24:48 +0100
Message-ID: <20050211032448.GD31837@postel.suug.ch>
References: <420BF8CB.6080005@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <420BF8CB.6080005@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Pablo Neira <420BF8CB.6080005@eurodev.net> 2005-02-11 01:14
> This patch introduces a new function called netlink_check_skb that does 
> the sanity checkings for received messages.

The patch description doesn't really match the patch itself.


> ===== net/netlink/af_netlink.c 1.69 vs edited =====
> --- 1.69/net/netlink/af_netlink.c	2005-01-21 21:25:32 +01:00
> +++ edited/net/netlink/af_netlink.c	2005-02-10 00:37:57 +01:00
> @@ -1201,6 +1201,42 @@
>  	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
>  }
>  
> +/* 
> + * Process one packet of messages.
> + * Malformed skbs with wrong lengths of messages are discarded silently.
> + */
> +int netlink_process_skb(struct sk_buff *skb, 
> +			int (*process_msg)(struct sk_buff *skb,
> +					   struct nlmsghdr *nlh,
> +					   int *err))
> +{
> +	int err;
> +	struct nlmsghdr * nlh;
> +
> +	while (skb->len >= NLMSG_SPACE(0)) {

While you're at it, change that to NLMSG_LENGTH(0) or even to
NLMSG_ALIGN(sizeof(*nlh)) to make it more readable. NLMSG_SPACE()
represents the total size of a netlink message in the byte stream
including the padding to payload in order to enforce proper
alignement for successive netlink message header.
