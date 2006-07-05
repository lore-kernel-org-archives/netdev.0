From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [PKT_SCHED]: Return ENOENT if action module is
	unavailable
Date: Tue, 04 Jul 2006 21:40:19 -0400
Message-ID: <1152063619.5199.5.camel@jzny2>
References: <20060704220504.787776000@postel.suug.ch>
	 <20060704220550.113899000@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:21692 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932442AbWGEBkV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 21:40:21 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FxwNP-0006q3-OO
	for netdev@vger.kernel.org; Tue, 04 Jul 2006 21:40:27 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060704220550.113899000@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-05-07 at 00:00 +0200, Thomas Graf wrote:
> plain text document attachment (act_fix_init_ret_val)
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Index: net-2.6.git/net/sched/act_api.c
> ===================================================================
> --- net-2.6.git.orig/net/sched/act_api.c
> +++ net-2.6.git/net/sched/act_api.c
> @@ -305,6 +305,7 @@ struct tc_action *tcf_action_init_1(stru
>  			goto err_mod;
>  		}
>  #endif
> +		*err = -ENOENT;
>  		goto err_out;
>  	}
>  

Ok, this falls under the LinuxWay(tm). Quick inspection of the qdisc
code reveals the same bug. The cls side seems fine - but i didnt spend
more than 30 secs. So why dont you fix the qdisc one while you are at
it?

Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

