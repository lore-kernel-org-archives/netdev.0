From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2.6.25] netns: struct net content re-work
Date: Mon, 10 Dec 2007 20:52:56 -0700
Message-ID: <m1prxd28h3.fsf@ebiederm.dsl.xmission.com>
References: <20071210163645.GA24030@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, containers@lists.osdl.org,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:45161 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbXLKDz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 22:55:28 -0500
In-Reply-To: <20071210163645.GA24030@iris.sw.ru> (Denis V. Lunev's message of
	"Mon, 10 Dec 2007 19:36:45 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The idea of separate structures make sense, and seems needed and useful.

"Denis V. Lunev" <den@openvz.org> writes:

> diff --git a/include/net/netns/unix.h b/include/net/netns/unix.h
> new file mode 100644
> index 0000000..27b4e7f
> --- /dev/null
> +++ b/include/net/netns/unix.h
                   ^^^^^^
Given that we are making this per protocol adding a separate directory
to hold them seems to be the wrong grouping.  Ideally we want everything
for the protocol all together in the same location so it is easy
to find.  Possibly with a user/kernel split.

So perhaps unix_net.h

> @@ -0,0 +1,13 @@
> +/*
> + * Unix network namespace
> + */
> +#ifndef __NETNS_UNIX_H__
> +#define __NETNS_UNIX_H__
> +
> +struct ctl_table_header;
> +struct netns_unix {
> +	int			sysctl_unix_max_dgram_qlen;
> +	struct ctl_table_header	*unix_ctl;
> +};

How about struct unix_net?  I think that tracks a little better
with how we have done struct in_device, ip6_dev and their friends.

Eric
