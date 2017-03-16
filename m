From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v4] net: ipv4: add support for ECMP hash policy
 choice
Date: Thu, 16 Mar 2017 09:41:52 -0700
Message-ID: <20170316094152.0ac70537@xeon-e3>
References: <1488884508-14016-1-git-send-email-nikolay@cumulusnetworks.com>
        <1489670880-12717-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        jkbs@redhat.com, edumazet@google.com, pch@ordbogen.com,
        nicolas.dichtel@6wind.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:35734 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753287AbdCPQmA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 12:42:00 -0400
Received: by mail-pg0-f53.google.com with SMTP id b129so27714660pgc.2
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 09:41:59 -0700 (PDT)
In-Reply-To: <1489670880-12717-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Mar 2017 15:28:00 +0200
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index d6880a6149ee..62c4f94923e5 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -1004,6 +1004,15 @@ static struct ctl_table ipv4_net_table[] = {
>  		.extra1		= &zero,
>  		.extra2		= &one,
>  	},
> +	{
> +		.procname	= "fib_multipath_hash_policy",
> +		.data		= &init_net.ipv4.sysctl_fib_multipath_hash_policy,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_minmax,
> +		.extra1		= &zero,
> +		.extra2		= &one,
> +	

Rather than having magic integer values, it would be better to use
strings (like TCP congestion control).  Especially if you want to support
more values in the future.

Also what about IPv6?
