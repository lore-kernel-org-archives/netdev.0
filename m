From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] PKT_SCHED: remove c99ism
Date: Sat, 15 Jan 2005 15:32:02 -0800
Message-ID: <20050115153202.2f7f81c6.akpm@osdl.org>
References: <20050115144010.33182075.akpm@osdl.org>
	<20050115232554.GS26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050115232554.GS26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf@suug.ch> wrote:
>
>  #ifdef CONFIG_NET_CLS_ACT
>  -	int err;
>  -	struct tc_action *act;
>  -
>   	if (map->police && tb[map->police-1]) {
>  +		int err;
>  +		struct tc_action *act;
>   		act = tcf_action_init_1(tb[map->police-1], rate_tlv, "police",
>   			TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
>   		if (act == NULL)
>  @@ -498,6 +497,8 @@
>   		act->type = TCA_OLD_COMPAT;
>   		exts->action = act;
>   	} else if (map->action && tb[map->action-1]) {
>  +		int err;
>  +		struct tc_action *act;
>   		act = tcf_action_init(tb[map->action-1], rate_tlv, NULL,
>   			TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
>   		if (act == NULL)

yes, that's the obvious one, but it uses a little more stack space.

An uglier but more efficient approach is to whack braces around the whole
thing.
