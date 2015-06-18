From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [PATCH net-next] switchdev: fdb filter_dev is always NULL for
 self (device), so remove check
Date: Wed, 17 Jun 2015 22:30:54 -0700
Message-ID: <5582578E.2000600@intel.com>
References: <1434582511-46290-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us
To: sfeldma@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64422 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751763AbbFRFa4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2015 01:30:56 -0400
In-Reply-To: <1434582511-46290-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 6/17/2015 4:08 PM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Remove the filter_dev check when dumping fdb entries, otherwise dump
> returns empty list.  filter_dev is always passed as NULL when dumping fdbs
> on SELF.  We want the fdbs installed on the device to be listed in the
> dump.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Sridhar Samudrala <sridhar.samudrala@intel.com>

> Fixes: 45d4122c ("switchdev: add support for fdb add/del/dump via switchdev_port_obj ops")
> ---
>   net/switchdev/switchdev.c |    6 ------
>   1 file changed, 6 deletions(-)
>
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index a5d0f8e..7dda437 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -657,7 +657,6 @@ struct switchdev_fdb_dump {
>   	struct switchdev_obj obj;
>   	struct sk_buff *skb;
>   	struct netlink_callback *cb;
> -	struct net_device *filter_dev;
>   	int idx;
>   };
>   
> @@ -670,14 +669,10 @@ static int switchdev_port_fdb_dump_cb(struct net_device *dev,
>   	u32 seq = dump->cb->nlh->nlmsg_seq;
>   	struct nlmsghdr *nlh;
>   	struct ndmsg *ndm;
> -	struct net_device *master = netdev_master_upper_dev_get(dev);
>   
>   	if (dump->idx < dump->cb->args[0])
>   		goto skip;
>   
> -	if (master && dump->filter_dev != master)
> -		goto skip;
> -
>   	nlh = nlmsg_put(dump->skb, portid, seq, RTM_NEWNEIGH,
>   			sizeof(*ndm), NLM_F_MULTI);
>   	if (!nlh)
> @@ -731,7 +726,6 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
>   		},
>   		.skb = skb,
>   		.cb = cb,
> -		.filter_dev = filter_dev,
>   		.idx = idx,
>   	};
>   	int err;
