From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/9] PKT_SCHED: tc filter extension API
Date: 30 Dec 2004 08:51:54 -0500
Message-ID: <1104414713.1047.130.camel@jzny.localdomain>
References: <20041230122652.GM32419@postel.suug.ch>
	 <20041230123023.GO32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041230123023.GO32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas,

Havent looked at the whole set - will later today; quick question:

On Thu, 2004-12-30 at 07:30, Thomas Graf wrote:

> +struct tcf_exts
> +{
> +#ifdef CONFIG_NET_CLS_ACT
> +	struct tc_action *action;
> +#elif defined CONFIG_NET_CLS_POLICE
> +	struct tcf_police *police;
> +#endif
> +};

Things like above:
In current code you can have CONFIG_NET_CLS_ACT and not use new
style policer, rather use old one i.e CONFIG_NET_CLS_POLICE. You seem to
indicate presence of CONFIG_NET_CLS_ACT implies absence of
NET_CLS_POLICE.
A fix for example maybe to s/elif/ifdef [1]

Anyways, back later to peek some more.

cheers,
jamal


[1]Look at Kconfig rules:

----
config NET_CLS_POLICE
        ...
        depends on NET_CLS && NET_QOS && NET_ACT_POLICE!=y &&  
NET_ACT_POLICE!=m
----

Anyways, back later to peek some more.

cheers,
jamal
