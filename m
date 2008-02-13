From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/4] rcu_assign_pointer: null check fix
Date: Wed, 13 Feb 2008 08:07:41 +0000
Message-ID: <20080213080741.GB2542@ff.dom.local>
References: <20080213005122.653836965@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernle.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:20397 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753645AbYBMIAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 03:00:32 -0500
Received: by nf-out-0910.google.com with SMTP id g13so1589844nfb.21
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2008 00:00:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080213005122.653836965@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-02-2008 01:50, Stephen Hemminger wrote:
...
> --- a/include/linux/rcupdate.h	2008-02-12 14:46:49.000000000 -0800
> +++ b/include/linux/rcupdate.h	2008-02-12 14:56:17.000000000 -0800
> @@ -178,7 +178,7 @@ struct rcu_head {
>  
>  #define rcu_assign_pointer(p, v)			\
>  	({						\
> -		if (!(__builtin_constant_p(v) && v))	\
> +		if (!__builtin_constant_p(v) || v)	\

Isn't it a bit safer with this Paul's version yet?:

 +		if (!__builtin_constant_p(v) || (v))	\

Jarek P.
