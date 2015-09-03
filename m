From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [patch net] switchdev: fix return value of switchdev_port_fdb_dump
 in case of error
Date: Thu, 03 Sep 2015 09:59:38 -0700
Message-ID: <55E87C7A.4020608@intel.com>
References: <1441281857-613-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43377 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751542AbbICQ7j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2015 12:59:39 -0400
In-Reply-To: <1441281857-613-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/3/2015 5:04 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> switchdev_port_fdb_dump is used as .ndo_fdb_dump. Its return value is
> idx, so we cannot return errval.
>
> Fixes: 45d4122ca7cd ("switchdev: add support for fdb add/del/dump via switchdev_port_obj ops.")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Sridhar Samudrala <sridhar.samudrala@intel.com>

> ---
>   net/switchdev/switchdev.c | 6 +-----
>   1 file changed, 1 insertion(+), 5 deletions(-)
>
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index 16c1c43..fda38f8 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -853,12 +853,8 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
>   		.cb = cb,
>   		.idx = idx,
>   	};
> -	int err;
> -
> -	err = switchdev_port_obj_dump(dev, &dump.obj);
> -	if (err)
> -		return err;
>   
> +	switchdev_port_obj_dump(dev, &dump.obj);
>   	return dump.idx;
>   }
>   EXPORT_SYMBOL_GPL(switchdev_port_fdb_dump);
