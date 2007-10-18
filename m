From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] Lost locking in fl6_sock_lookup
Date: Thu, 18 Oct 2007 05:16:47 -0700 (PDT)
Message-ID: <20071018.051647.23015283.davem@davemloft.net>
References: <47174950.6060409@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33181
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763325AbXJRMQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 08:16:33 -0400
In-Reply-To: <47174950.6060409@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 18 Oct 2007 15:53:52 +0400

> This routine scans the ipv6_fl_list whose update is
> protected with the socket lock and the ip6_sk_fl_lock.
> 
> Since the socket lock is not taken in the lookup, use
> the other one.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.

But I notice that I was wrong in my email, we don't
hold the socket lock here.

What prevents an unlink from the socket's list
and thus a reference count of zero occurring for
a brief moment?
