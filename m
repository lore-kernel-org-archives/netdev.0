From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation
Date: Thu, 08 Feb 2007 14:01:50 -0800 (PST)
Message-ID: <20070208.140150.48808723.davem@davemloft.net>
References: <20070208163211.23973.5877.stgit@warthog.cambridge.redhat.com>
	<20070209.015539.53640067.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org, herbert.xu@redhat.com,
	hch@infradead.org, arjan@infradead.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56513
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1945902AbXBHWBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 17:01:51 -0500
In-Reply-To: <20070209.015539.53640067.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Fri, 09 Feb 2007 01:55:39 +0900 (JST)

> In article <20070208163211.23973.5877.stgit@warthog.cambridge.redhat.com> (at Thu, 08 Feb 2007 16:32:11 +0000), David Howells <dhowells@redhat.com> says:
> 
> >  (2) A local address can optionally be bound:
> > 
> > 	struct sockaddr_rxrpc srx = {
> > 		.srx_family	= AF_RXRPC,
> > 		.srx_service	= 0,  /* we're a client */
> > 		.transport_type	= SOCK_DGRAM,	/* type of transport socket */
> > 		.transport.sin_family	= AF_INET,
> > 		.transport.sin_port	= htons(7000), /* AFS callback */
> > 		.transport.sin_address	= 0,  /* all local interfaces */
> > 	};
> 
> This sockaddr_rxrpc{} should NOT include sockaddr_in{} directly.
> Please use sockaddr_storage{} (or sockaddr{}, maybe), and make it
> sure to align on 64-bit word.

This is correct.

David, we should make the suggested changes in order to support IPv6
(and theoretically other address families as the transport) cleanly.
