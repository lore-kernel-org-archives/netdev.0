From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net] ipv4: igmp: Allow removing groups from a removed
 interface
Date: Mon, 30 Nov 2015 11:01:48 -0500 (EST)
Message-ID: <20151130.110148.959343190265894374.davem@redhat.com>
References: <1448482536-26081-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37473 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751484AbbK3QBt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2015 11:01:49 -0500
In-Reply-To: <1448482536-26081-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 25 Nov 2015 21:15:36 +0100

> @@ -2126,7 +2126,7 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
>  	ASSERT_RTNL();
>  
>  	in_dev = ip_mc_find_dev(net, imr);
> -	if (!in_dev) {
> +	if (!imr->imr_ifindex && !imr->imr_address.s_addr && !in_dev) {
>  		ret = -ENODEV;
>  		goto out;
>  	}

Now, ip_mc_dec_group() below can take a NULL pointer dereference.  One example
is if imr_ifindex is specified and the lookup returns NULL in ip_mc_find_dev().

This is so rediculously complicated, just looking at this code breaks something.
