From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH 2/8] dcbnl: Shorten all command handling functions
Date: Wed, 20 Jun 2012 23:04:49 -0700
Message-ID: <4FE2B981.6010704@intel.com>
References: <cover.1339591572.git.tgraf@suug.ch> <3fea99383d5ee98b51bd8b0088bed38cdb59f375.1339591572.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, lucy.liu@intel.com,
	alexander.h.duyck@intel.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:42568 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758618Ab2FUGEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2012 02:04:52 -0400
In-Reply-To: <3fea99383d5ee98b51bd8b0088bed38cdb59f375.1339591572.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/13/2012 5:54 AM, Thomas Graf wrote:
> Allocating and sending the skb in dcb_doit() allows for much
> shorter and cleaner command handling functions.
>
> The huge switch statement is replaced with an array based definition
> of the handling function and reply message type.
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>   net/dcb/dcbnl.c |  722 +++++++++++++------------------------------------------
>   1 files changed, 172 insertions(+), 550 deletions(-)
>

[...]

> @@ -1054,32 +885,27 @@ static int __dcbnl_pg_setcfg(struct net_device *netdev, struct nlattr **tb,
>   		}
>   	}
>
> -	ret = dcbnl_reply(0, RTM_SETDCB,
> -			  (dir ? DCB_CMD_PGRX_SCFG : DCB_CMD_PGTX_SCFG),
> -			  DCB_ATTR_PG_CFG, pid, seq, flags);
> +	ret = nla_put_u8(skb, (dir ? DCB_CMD_PGRX_SCFG : DCB_CMD_PGTX_SCFG), 0);

Previously, this returned DCB_ATTR_PG_CFG now it is returning RX or TX
variants. Although I like this implementation better I think in order
to not break user space application we should keep the previous
behavior. At least one app is checking these return codes.

I'll post a patch shortly. Thomas if you ACK it that would be great.

Thanks,
John
