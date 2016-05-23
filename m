From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Fix non-initialized TTL when CONFIG_SYSCTL=n
Date: Mon, 23 May 2016 14:33:18 -0700 (PDT)
Message-ID: <20160523.143318.293951661657795088.davem@davemloft.net>
References: <1463761270-8955-1-git-send-email-ezequiel@vanguardiasur.com.ar>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@kyup.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: ezequiel@vanguardiasur.com.ar
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50517 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbcEWVdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 17:33:20 -0400
In-Reply-To: <1463761270-8955-1-git-send-email-ezequiel@vanguardiasur.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>
Date: Fri, 20 May 2016 13:21:10 -0300

> Commit fa50d974d104 ("ipv4: Namespaceify ip_default_ttl sysctl knob")
> moves the default TTL assignment, and as side-effect IPv4 TTL now
> has a default value only if sysctl support is enabled (CONFIG_SYSCTL=y).
> 
> The sysctl_ip_default_ttl is fundamental for IP to work properly,
> as it provides the TTL to be used as default. The defautl TTL may be
> used in ip_selected_ttl, through the following flow:
> 
>   ip_select_ttl
>     ip4_dst_hoplimit
>       net->ipv4.sysctl_ip_default_ttl
> 
> This commit fixes the issue by assigning net->ipv4.sysctl_ip_default_ttl
> in net_init_net, called during ipv4's initialization.
> 
> Without this commit, a kernel built without sysctl support will send
> all IP packets with zero TTL (unless a TTL is explicitly set, e.g.
> with setsockopt).
> 
> Given a similar issue might appear on the other knobs that were
> namespaceify, this commit also moves them.
> 
> Fixes: fa50d974d104 ("ipv4: Namespaceify ip_default_ttl sysctl knob")
> Signed-off-by: Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>

Applied and queued up for -stable, thanks.
