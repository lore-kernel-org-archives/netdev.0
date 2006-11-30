From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PKT_SCHED] act_gact: division by zero
Date: Thu, 30 Nov 2006 13:17:09 +0100
Message-ID: <456ECBC5.3080501@trash.net>
References: <Pine.LNX.4.44.0611301309550.14993-100000@dhcp09282.ntc.nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57282 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S936317AbWK3MRQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 07:17:16 -0500
To: "Nordlund Kim (Nokia-NET/Helsinki)" <Kim.Nordlund@nokia.com>
In-Reply-To: <Pine.LNX.4.44.0611301309550.14993-100000@dhcp09282.ntc.nokia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nordlund Kim (Nokia-NET/Helsinki) wrote:
> tc qdisc add dev eth1 handle ffff: ingress
> tc filter add dev eth1 protocol ip parent ffff: pref 99 basic \
>    flowid 1:1 action pass random determ drop 0
>                                              ^
> the above cause a division by zero in the kernel on the first
> packet in.
> 
> Signed-off-by: Kim Nordlund <kim.nordlund@nokia.com>
> 
> diff -rub linux-2.6.19-orig/net/sched/act_gact.c linux/net/sched/act_gact.c
> --- linux-2.6.19-orig/net/sched/act_gact.c	2006-11-29 23:57:37.000000000 +0200
> +++ linux/net/sched/act_gact.c	2006-11-30 13:22:37.000000000 +0200
> @@ -111,7 +111,7 @@
>  	if (tb[TCA_GACT_PROB-1] != NULL) {
>  		struct tc_gact_p *p_parm = RTA_DATA(tb[TCA_GACT_PROB-1]);
>  		gact->tcfg_paction = p_parm->paction;
> -		gact->tcfg_pval    = p_parm->pval;
> +		gact->tcfg_pval    = p_parm->pval ? : 1;


I think it should reject an invalid configuration or handle
the zero case correctly by not dividing.
