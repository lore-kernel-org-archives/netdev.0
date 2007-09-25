From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Tue, 25 Sep 2007 09:41:38 -0300
Message-ID: <20070925124138.GC18348@ghostprotocols.net>
References: <20070925122029.15989.0@janus.isnogud.escape.de> <20070925122243.15989.2@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Joe Perches <joe@perches.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:59781 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbXIYMlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 08:41:46 -0400
Received: by an-out-0708.google.com with SMTP id d31so279448and
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2007 05:41:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070925122243.15989.2@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Sep 25, 2007 at 02:20:31PM +0200, Urs Thuermann escreveu:
> +
> +static void can_sock_destruct(struct sock *sk)
> +{
> +	DBG("called for sock %p\n", sk);
> +
> +	skb_queue_purge(&sk->sk_receive_queue);
> +	if (sk->sk_protinfo)
> +		kfree(sk->sk_protinfo);
> +}

Is it really needed to do this sk_protinfo check? You don't use it and
it is going to be removed (only user is one of the HAM radio protocols),
so it would be better to not add any more references to this struct sock
field.

- Arnaldo
