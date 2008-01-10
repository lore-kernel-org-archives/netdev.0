From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6.23+] ingress classify to [nf]mark
Date: Thu, 10 Jan 2008 16:39:27 -0500
Message-ID: <1200001167.4443.38.camel@localhost>
References: <47866C69.3080904@bspu.unibel.by>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mahatma@eu.by
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:65249 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbYAJVjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 16:39:35 -0500
Received: by py-out-1112.google.com with SMTP id u52so1245251pyb.10
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 13:39:33 -0800 (PST)
In-Reply-To: <47866C69.3080904@bspu.unibel.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-10-01 at 17:05 -0200, Dzianis Kahanovich wrote:
> To "classid x:y" = "mark=mark&x|y" ("classid :y" = "-j MARK --set-mark y", etc).
> 
> --- linux-2.6.23-gentoo-r2/net/sched/Kconfig
> +++ linux-2.6.23-gentoo-r2.fixed/net/sched/Kconfig
> @@ -222,6 +222,16 @@
[..]
>   			skb->tc_index = TC_H_MIN(res.classid);
> +#ifdef CONFIG_NET_SCH_INGRESS_TC2MARK
> +			skb->mark = (skb->mark&(res.classid>>16))|TC_H_MIN(res.classid);
> +#endif
>   		default:


Please either use ipt action and netfilter fwmarker for this activity or
create a new action. 
If you choose the later (example because you want to dynamically compute
the mark), look at net/sched/act_simple.c to start from and i can help
you if you have any questions.
 
If you want to use ipt action, the syntax would be something like:

---
tc qdisc add dev XXX ingress
tc filter add dev XXX parent ffff: protocol ip prio 5 \
u32 blah bleh \
flowid 1:12 action ipt -j mark --set-mark 13 
-----

cheers,
jamal

