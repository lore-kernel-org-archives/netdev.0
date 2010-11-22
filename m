From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 4/9] AF_UNIX: find the recipients for multicast messages
Date: Mon, 22 Nov 2010 21:14:52 +0100
Message-ID: <87hbf9uncz.fsf@basil.nowhere.org>
References: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
	<1290450982-17480-4-git-send-email-alban.crequy@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Ian Molton <ian.molton@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290450982-17480-4-git-send-email-alban.crequy@collabora.co.uk>
	(Alban Crequy's message of "Mon, 22 Nov 2010 18:36:17 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alban Crequy <alban.crequy@collabora.co.uk> writes:

>+static DEFINE_SPINLOCK(unix_multicast_lock);

For DBUS it's probably ok, but I suspect for other usages
the global lock in the multipath fast path is going to hurt
sooner or later.

> +
> +        /* Allocate for the set and hope the number of recipients does not
> +	 * change while the lock is released. If it changes, we have to try
> +	 * again... We allocate a bit more than needed, so if a _few_ members
> +	 * are added in a multicast group meanwhile, we don't always need to
> +	 * try again. */
> +	recipient_cnt += 5;
> +
> +	set = kmalloc(sizeof(struct sock_set)
> +		      + sizeof(struct sock_item) * recipient_cnt,
> +	    GFP_KERNEL);

FWIW for a large number of sockets this will likely run into
memory fragmentation issues. There are various workarounds like
fallback to vmalloc or use something like flex_arrays.


-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
