From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] net: tcp_probe: add IPv6 support
Date: Thu, 22 Aug 2013 13:43:09 -0700 (PDT)
Message-ID: <20130822.134309.2073296501906078763.davem@davemloft.net>
References: <1377107280-31091-1-git-send-email-dborkman@redhat.com>
	<1377107280-31091-4-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52494 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868Ab3HVUnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 16:43:10 -0400
In-Reply-To: <1377107280-31091-4-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 21 Aug 2013 19:48:00 +0200

> +	union {
> +		struct sockaddr		raw;
> +		struct sockaddr_in	v4;
> +		struct sockaddr_in6	v6;
> +	}	src, dst;

This bloats up the tcp_log structure unnecessarily.  You have
absolutely no use for the port member, for example.

I know you want to use this so that you can be lazy and only
use the single printf format specifier.  Here, keeping the
tcp_log compact is more important.
