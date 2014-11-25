From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH rfc 2/4] net-errqueue: add IP(V6)_PKTINFO support
Date: Tue, 25 Nov 2014 13:41:02 -0500 (EST)
Message-ID: <20141125.134102.1488230781371300774.davem@davemloft.net>
References: <1416938286-14147-1-git-send-email-willemb@google.com>
	<1416938286-14147-3-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, luto@amacapital.net,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045AbaKYSlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 13:41:05 -0500
In-Reply-To: <1416938286-14147-3-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Tue, 25 Nov 2014 12:58:04 -0500

> +	if (inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO && skb->dev) {
> +		struct in_pktinfo info = {0};

I think memset(&info... is cleaner, and:

> +		struct in6_pktinfo info;
> +
> +		memset(&info, 0, sizeof(info));

Would make the code consistent with the ipv6 side.
