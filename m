From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3 net-next 3/5] sock: ULP infrastructure
Date: Tue, 08 Aug 2017 12:38:58 -0400
Message-ID: <87shh2t3od.fsf@stressinduktion.org>
References: <20170807172818.31855-1-tom@quantonium.net>
        <20170807172818.31855-4-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, rohit@quantonium.net, davejwatson@fb.com,
        john.fastabend@gmail.com
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:39141 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752082AbdHHQjA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 12:39:00 -0400
In-Reply-To: <20170807172818.31855-4-tom@quantonium.net> (Tom Herbert's
        message of "Mon, 7 Aug 2017 10:28:16 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@quantonium.net> writes:

> +#ifdef CONFIG_MODULES
> +	if (!ulp && capable(CAP_NET_ADMIN)) {
> +		rcu_read_unlock();
> +		request_module("%s", name);
> +		rcu_read_lock();
> +		ulp = ulp_find(name);
> +	}
> +#endif

It looks to me that this allows users with only CAP_NET_ADMIN
privileges to load every module?
