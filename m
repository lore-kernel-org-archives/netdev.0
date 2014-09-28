From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2] bond_slave: add help and fail on unknown opt
Date: Sun, 28 Sep 2014 15:56:25 -0700
Message-ID: <20140928155625.59234ddb@urahara>
References: <1409759850-15812-1-git-send-email-nikolay@redhat.com>
	<1409903125-21200-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nikolay@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:57315 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753257AbaI1W4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 18:56:40 -0400
Received: by mail-pa0-f50.google.com with SMTP id kx10so2173197pab.9
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 15:56:39 -0700 (PDT)
In-Reply-To: <1409903125-21200-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  5 Sep 2014 09:45:25 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  ip/iplink_bond_slave.c | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> diff --git a/ip/iplink_bond_slave.c b/ip/iplink_bond_slave.c
> index aacba14..3c26f08 100644
> --- a/ip/iplink_bond_slave.c
> +++ b/ip/iplink_bond_slave.c
> @@ -17,6 +17,13 @@
>  #include "utils.h"
>  #include "ip_common.h"
>  
> +static void explain(void)
> +{
> +	fprintf(stderr,
> +		"Usage: ... bond_slave [ queue_id QUEUE_ID ]\n"
> +	);
> +}
> +
>  static const char *slave_states[] = {
>  	[BOND_STATE_ACTIVE] = "ACTIVE",
>  	[BOND_STATE_BACKUP] = "BACKUP",
> @@ -91,6 +98,14 @@ static int bond_slave_parse_opt(struct link_util *lu, int argc, char **argv,
>  			if (get_u16(&queue_id, *argv, 0))
>  				invarg("queue_id is invalid", *argv);
>  			addattr16(n, 1024, IFLA_BOND_SLAVE_QUEUE_ID, queue_id);
> +		} else if (matches(*argv, "help") == 0) {
> +			explain();
> +			return -1;
> +		} else {
> +			fprintf(stderr, "bond_slave: unknown option \"%s\"?\n",
> +				*argv);
> +			explain();
> +			return -1;
>  		}
>  		argc--, argv++;
>  	}

This patch does not apply. there is probably some earlier patch you forgot to send about
BOND_SLAVE_QUEUE_ID.
