From: Patrick McHardy <kaber@trash.net>
Subject: Re: [1/1] connector: add userspace example code into Documentation/connector/
Date: Fri, 25 Aug 2006 08:57:23 +0200
Message-ID: <44EE9F53.2090303@trash.net>
References: <20060825064956.GA20468@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53394 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750721AbWHYG50
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 02:57:26 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060825064956.GA20468@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Hello.
> 
> I was asked several times to include userspace example code into
> Documentation, so if there is no policy against it, consider attached patch 
> for 2.6.18. This program works with included Documentation/connector/cn_test.c 
> connector module.

> +	l_local.nl_family = AF_NETLINK;
> +	l_local.nl_groups = 0x123;
> +	l_local.nl_pid = 0;
> +
> +	if (bind(s, (struct sockaddr *)&l_local, sizeof(struct sockaddr_nl)) == -1) {
> +		perror("bind");
> +		close(s);
> +		return -1;
> +	}
> +
> +	{
> +		int on = l_local.nl_groups;
> +		setsockopt(s, 270, 1, &on, sizeof(on));
> +	}

Example code shouldn't use magic numbers, please use the proper defines.
And the code is wrong, using the same group number for bind (which takes
a bitmask) and setsockopt (which takes a group number) doesn't work.
Its not necessary to use setsockopt if you already used bind anyway.

