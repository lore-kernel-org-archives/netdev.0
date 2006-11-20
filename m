From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] AF_UNIX recv/shutdown race
Date: Mon, 20 Nov 2006 13:05:17 +0100
Message-ID: <20061120120517.GD1001@ff.dom.local>
References: <51488.68.160.147.35.1163979646.squirrel@webmail.metacarta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:48069 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S934080AbWKTL66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 06:58:58 -0500
Received: from ff.dom.local (bv170.internetdsl.tpnet.pl [80.53.205.170])
	by poczta.o2.pl (Postfix) with ESMTP id 85A81628096
	for <netdev@vger.kernel.org>; Mon, 20 Nov 2006 12:58:57 +0100 (CET)
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <51488.68.160.147.35.1163979646.squirrel@webmail.metacarta.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20-11-2006 00:40, jmalicki@metacarta.com wrote:
...
> @@ -650,7 +651,7 @@ static int unix_autobind(struct socket *
>  	struct unix_address * addr;
>  	int err;
> 
> -	mutex_lock(&u->readlock);
> +	unix_state_rlock(sk);

Here follows:
        err = 0;
        if (u->addr)
                goto out;

        err = -ENOMEM;
        addr = kzalloc(sizeof(*addr) + sizeof(short) + 16, GFP_KERNEL);
        if (!addr)
                goto out;

Are you sure you can use spin_lock here? 

Jarek P.

