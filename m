From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] act_mirred: cleanup and optimization
Date: Fri, 13 Nov 2009 08:13:11 +0100
Message-ID: <4AFD0707.50207@trash.net>
References: <4AFCF06B.1090602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43332 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbZKMHNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 02:13:07 -0500
In-Reply-To: <4AFCF06B.1090602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> act_mirred: cleanup and optimization.
> 
> cleanup and optimization.
> 1. don't let go back using goto.
> 2. move checking if eaction is valid in tcf_mirred_init().
> 3. don't call skb_act_clone() until it is necessary.
> 4. one exit of the critical context.
> 5. allow eaction is TCA_INGRESS_MIRROR & TCA_INGRESS_REDIR.
> 

>  	if (parm->ifindex) {
> -		dev = __dev_get_by_index(&init_net, parm->ifindex);
> +		dev = dev_get_by_index(&init_net, parm->ifindex);
>  		if (dev == NULL)
>  			return -ENODEV;

This change is not mentioned in the changelog and introduces a
leak. Please split your patches into reasonable portions doing
one change at a time.
