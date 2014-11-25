From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH rfc 3/4] net-timestamp: tcp sockets return v6 errors on
 v6 sockets
Date: Tue, 25 Nov 2014 13:41:52 -0500 (EST)
Message-ID: <20141125.134152.1265765328256853180.davem@davemloft.net>
References: <1416938286-14147-1-git-send-email-willemb@google.com>
	<1416938286-14147-4-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, luto@amacapital.net,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbaKYSly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 13:41:54 -0500
In-Reply-To: <1416938286-14147-4-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Tue, 25 Nov 2014 12:58:05 -0500

> From: Willem de Bruijn <willemb@google.com>
> 
> TCP timestamping introduced MSG_ERRQUEUE handling for TCP sockets.
> It always passed errorqueue requests onto ip_recv_error, but the
> same tcp_recvmsg code may also be called for IPv6 sockets. In that
> case, pass to ipv6_recv_error.
> 
> Tested by asking for PKTINFO with
> 
>   Documentation/networking/timestamping/txtimestamp -I
> 
> Before this change, IPv6 sockets would return AF_INET/IP_PKTINFO
> after the change, these sockets return AF_INET6/IPV6_PKTINFO
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

This looks like a bug fix to me, and is therefore probably 'net'
material.
