From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: abort orphan sockets stalling on zero
 window probes
Date: Fri, 26 Sep 2014 15:56:11 -0400 (EDT)
Message-ID: <20140926.155611.954320324745536887.davem@davemloft.net>
References: <1411444333-6013-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, andrey.dmitrov@oktetlabs.ru,
	ncardwell@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754335AbaIZT4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 15:56:14 -0400
In-Reply-To: <1411444333-6013-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon, 22 Sep 2014 20:52:13 -0700

> -
> +		if (!alive && icsk->icsk_backoff >= max_probes)
> +			goto abort;
>  		if (tcp_out_of_resources(sk, alive || icsk->icsk_probes_out <= max_probes))
>  			return;

This new logic means that the second argument to tcp_out_of_resources()
will always be 'true'.

Please make that explicit, because the code is confusing otherwise.

Also perhaps target this for the 'net' tree?

Thanks.
