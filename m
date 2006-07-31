From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6]: Audit all ip6_dst_lookup/ip6_dst_store calls
Date: Sun, 30 Jul 2006 20:56:23 -0700 (PDT)
Message-ID: <20060730.205623.91207946.davem@davemloft.net>
References: <20060729043325.GA7035@gondor.apana.org.au>
	<20060730.154416.121293840.davem@davemloft.net>
	<20060731033210.GD31083@humbolt.us.dell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48524
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751069AbWGaD4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 23:56:12 -0400
To: Matt_Domsch@dell.com
In-Reply-To: <20060731033210.GD31083@humbolt.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Domsch <Matt_Domsch@dell.com>
Date: Sun, 30 Jul 2006 22:32:10 -0500

> swapper/0 is trying to acquire lock:
>  (slock-AF_INET6){-+..}, at: [<ffffffff80414fda>] sk_clone+0xd2/0x3a8
> 
> but task is already holding lock:
>  (slock-AF_INET6){-+..}, at: [<ffffffff883d71a8>] tcp_v6_rcv+0x30e/0x76e [ipv6]

The tcp_v6_rcv() code path is holding the slock on the parent
listening socket, whereas in sk_clone() we have grabbed the
socket slock on the newly allocated "newsk" socket.  These
are thus two seperate locks, although they are in the same
locking class "slock-AF_INET6".

I don't know why the lock validator is complaining about this.
