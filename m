From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] INET: fix incorrect "inet_sock->is_icsk" assignment
Date: Mon, 8 Jan 2007 14:25:48 +0100
Message-ID: <20070108132548.GA2324@ff.dom.local>
References: <20070104200437.008980288@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:59504 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751527AbXAHNX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jan 2007 08:23:59 -0500
To: Paul Moore <paul.moore@hp.com>
Content-Disposition: inline
In-Reply-To: <20070104200437.008980288@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04-01-2007 21:04, Paul Moore wrote:
...
> +++ net-2.6.20_bugfix_2/net/ipv4/af_inet.c
> @@ -305,7 +305,7 @@ lookup_protocol:
>  		sk->sk_reuse = 1;
>  
>  	inet = inet_sk(sk);
> -	inet->is_icsk = INET_PROTOSW_ICSK & answer_flags;
> +	inet->is_icsk = (INET_PROTOSW_ICSK & answer_flags) == INET_PROTOSW_ICSK;

Isn't this more readable like this?:
 
inet->is_icsk = (INET_PROTOSW_ICSK & answer_flags) != 0;

Regards,
Jarek P.
