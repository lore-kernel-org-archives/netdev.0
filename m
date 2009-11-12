From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] ipv4: speedup inet_dump_ifaddr()
Date: Thu, 12 Nov 2009 09:12:21 -0800
Message-ID: <20091112091221.3d523253@nehalam>
References: <4AFC1798.1060501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33779 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753439AbZKLRMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2009 12:12:37 -0500
In-Reply-To: <4AFC1798.1060501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Nov 2009 15:11:36 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> When handling large number of netdevices, inet_dump_ifaddr()
> is very slow because it has O(N^2) complexity.
> 
> Instead of scanning one single list, we can use the NETDEV_HASHENTRIES
> sub lists of the dev_index hash table, and RCU lookups.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

You might be able to make RCU critical section smaller by moving
it into loop.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
