From: Herbert Poetzl <herbert@13thfloor.at>
Subject: Re: [PATCH] PKT_SCHED: remove c99ism
Date: Mon, 17 Jan 2005 10:09:12 +0100
Message-ID: <20050117090912.GB30371@mail.13thfloor.at>
References: <20050115144010.33182075.akpm@osdl.org> <20050115232554.GS26856@postel.suug.ch> <20050115153202.2f7f81c6.akpm@osdl.org> <20050115234056.GT26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050115234056.GT26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jan 16, 2005 at 12:40:56AM +0100, Thomas Graf wrote:
> * Andrew Morton <20050115153202.2f7f81c6.akpm@osdl.org> 2005-01-15 15:32
> > An uglier but more efficient approach is to whack braces around the whole
> > thing.
> 
> Fine with me as well. The code isn't used that often and not deep in the
> calling stack which is why I preferred the cleaner way first.

hmm, please remind me why putting some

#ifdef CONFIG_NET_CLS_ACT
	int err;
	struct tc_action *act;
#endif

at the _beginning_ of that procedure would
be a bad choice?

TIA,
Herbert

> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> --- linux-2.6.11-rc1-bk2.orig/net/sched/cls_api.c	2005-01-16 00:04:40.000000000 +0100
> +++ linux-2.6.11-rc1-bk2/net/sched/cls_api.c	2005-01-16 00:34:53.000000000 +0100
> @@ -486,24 +486,26 @@
>  	memset(exts, 0, sizeof(*exts));
>  	
>  #ifdef CONFIG_NET_CLS_ACT
> -	int err;
> -	struct tc_action *act;
> +	{
> +		int err;
> +		struct tc_action *act;
>  
> -	if (map->police && tb[map->police-1]) {
> -		act = tcf_action_init_1(tb[map->police-1], rate_tlv, "police",
> -			TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
> -		if (act == NULL)
> -			return err;
> -
> -		act->type = TCA_OLD_COMPAT;
> -		exts->action = act;
> -	} else if (map->action && tb[map->action-1]) {
> -		act = tcf_action_init(tb[map->action-1], rate_tlv, NULL,
> -			TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
> -		if (act == NULL)
> -			return err;
> +		if (map->police && tb[map->police-1]) {
> +			act = tcf_action_init_1(tb[map->police-1], rate_tlv, "police",
> +				TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
> +			if (act == NULL)
> +				return err;
> +
> +			act->type = TCA_OLD_COMPAT;
> +			exts->action = act;
> +		} else if (map->action && tb[map->action-1]) {
> +			act = tcf_action_init(tb[map->action-1], rate_tlv, NULL,
> +				TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
> +			if (act == NULL)
> +				return err;
>  
> -		exts->action = act;
> +			exts->action = act;
> +		}
>  	}
>  #elif defined CONFIG_NET_CLS_POLICE
>  	if (map->police && tb[map->police-1]) {
