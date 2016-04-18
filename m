From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tun: don't require serialization lock on tx
Date: Mon, 18 Apr 2016 14:36:40 -0400 (EDT)
Message-ID: <20160418.143640.1078793728710842442.davem@davemloft.net>
References: <cc7ac4631f0a32c4d61b73f4f28b52a05ab8651d.1460651429.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, hannes@stressinduktion.org,
	ebiederm@xmission.com, gkurz@linux.vnet.ibm.com,
	jasowang@redhat.com, edumazet@google.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54964 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbcDRSgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 14:36:47 -0400
In-Reply-To: <cc7ac4631f0a32c4d61b73f4f28b52a05ab8651d.1460651429.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Thu, 14 Apr 2016 18:39:39 +0200

> The current tun_net_xmit() implementation don't need any external
> lock since it relies on rcu protection for the tun data structure
> and on socket queue lock for skb queuing.
> 
> This patch set the NETIF_F_LLTX feature bit in the tun device, so
> that on xmit, in absence of qdisc, no serialization lock is acquired
> by the caller.
> 
> The user space can remove the default tun qdisc with:
> 
> tc qdisc replace dev <tun device name> root noqueue
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
