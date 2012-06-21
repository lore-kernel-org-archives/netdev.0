From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH] net: dcb: fix small regression in __dcbnl_pg_setcfg()
Date: Thu, 21 Jun 2012 04:19:10 -0400
Message-ID: <20120621081910.GH27921@canuck.infradead.org>
References: <20120621055621.14148.42206.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, davem@davemloft.net, netdev@vger.kernel.org,
	lucy.liu@intel.com, alexander.h.duyck@intel.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:57791 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758714Ab2FUITR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 04:19:17 -0400
Content-Disposition: inline
In-Reply-To: <20120621055621.14148.42206.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 20, 2012 at 10:56:21PM -0700, John Fastabend wrote:
> A small regression was introduced in the reply command of
> dcbnl_pg_setcfg(). User space apps may be expecting the
> DCB_ATTR_PG_CFG attribute to be returned with the patch
> below TX or RX variants are returned.
> 
> commit 7be994138b188387691322921c08e19bddf6d3c5
> Author: Thomas Graf <tgraf@suug.ch>
> Date:   Wed Jun 13 02:54:55 2012 +0000
> 
>     dcbnl: Shorten all command handling functions
> 
> This patch reverts this behavior and returns DCB_ATTR_PG_CFG
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 
>  net/dcb/dcbnl.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
> index 0a36007..013da86 100644
> --- a/net/dcb/dcbnl.c
> +++ b/net/dcb/dcbnl.c
> @@ -852,8 +852,7 @@ static int __dcbnl_pg_setcfg(struct net_device *netdev, struct nlmsghdr *nlh,
>  		}
>  	}
>  
> -	return nla_put_u8(skb,
> -			  (dir ? DCB_CMD_PGRX_SCFG : DCB_CMD_PGTX_SCFG), 0);
> +	return nla_put_u8(skb, DCB_ATTR_PG_CFG, 0);
>  }
>  

ACK

Thanks John
