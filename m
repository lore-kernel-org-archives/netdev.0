From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/llc/llc_conn.c: fix possible NULL dereference
Date: Fri, 18 May 2007 23:03:53 -0700 (PDT)
Message-ID: <20070518.230353.71553281.davem@davemloft.net>
References: <464E8763.3010609@redhat.com>
	<20070518223005.91236c38.randy.dunlap@oracle.com>
	<464E8FD7.9030203@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@redhat.com, randy.dunlap@oracle.com
To: eteo@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38142
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753643AbXESGDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2007 02:03:51 -0400
In-Reply-To: <464E8FD7.9030203@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eugene Teo <eteo@redhat.com>
Date: Sat, 19 May 2007 13:49:11 +0800

> Spotted by the Coverity checker.

Why am I not surprised :-(

There is no bug here, if Coverity warns every single time skb_peek()
is used and not tested against NULL, that's a very serious shortcoming
of Coverity or what it has been taught about SKB queues.

It needs to learn that skb_queue_len() != 0 implies skb_peek() will
not return NULL sans locking errors.
