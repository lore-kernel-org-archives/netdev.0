From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvtap: remove wrong sock_put() in macvtap_put_queue()
Date: Thu, 16 Jun 2011 22:58:25 -0400 (EDT)
Message-ID: <20110616.225825.127982592225091945.davem@davemloft.net>
References: <1307934919-4189-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46226 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813Ab1FQC6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 22:58:35 -0400
In-Reply-To: <1307934919-4189-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Mon, 13 Jun 2011 11:15:19 +0800

> The calling of sock_put() should be delayed after synchronize_rcu(),
> otherwise inconsist data may be seen during packets transmitting.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

You're leaking sockets now.

This function has to release the socket twice if there is
a non-NULL vlan assigned to the queue.

Now you're only doing it once in that situation.

Which probably fixes your crash, but adds a socket leak.
