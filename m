From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 net-next 5/8] net/ncsi: Dump NCSI packet statistics
Date: Thu, 13 Apr 2017 03:50:40 -0700
Message-ID: <1492080640.28586.15.camel@perches.com>
References: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
         <1492069701-20772-6-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0079.hostedemail.com ([216.40.44.79]:35662 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750952AbdDMKuq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 06:50:46 -0400
In-Reply-To: <1492069701-20772-6-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-13 at 17:48 +1000, Gavin Shan wrote:
> This creates /sys/kernel/debug/ncsi/<eth0>/stats to dump the NCSI
> packets sent and received over all packages and channels. It's useful
> to diagnose NCSI problems, especially when NCSI packages and channels
> aren't probed properly.

trivia:

> diff --git a/net/ncsi/ncsi-debug.c b/net/ncsi/ncsi-debug.c
> index 6c00e9b..29c233c 100644
> --- a/net/ncsi/ncsi-debug.c
> +++ b/net/ncsi/ncsi-debug.c
> @@ -23,6 +23,235 @@
>  #include "ncsi-pkt.h"
>  
>  static struct dentry *ncsi_dentry;
> +static struct ncsi_pkt_handler {

static const struct etc...

> +	unsigned char	type;
> +	const char	*name;
> +} ncsi_pkt_handlers[] = {
> +	{ NCSI_PKT_CMD_CIS,    "CIS"    },
[]
> +static bool ncsi_dev_stats_index(struct ncsi_dev_priv *ndp, loff_t pos,
> +				 unsigned long *type, unsigned long *index,
> +				 unsigned long *entries)
> +{
> +	int i;
> +	unsigned long ranges[3][2] = {
> +		{ 1,
> +		  ARRAY_SIZE(ndp->stats.cmd) - 1		},
> +		{ ranges[0][1] + 2,
> +		  ranges[1][0] + ARRAY_SIZE(ndp->stats.rsp) - 1	},
> +		{ ranges[1][1] + 2,
> +		  ranges[2][0] + ARRAY_SIZE(ndp->stats.aen) - 1 }
> +	};

const?
