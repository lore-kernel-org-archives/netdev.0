From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation
Date: Fri, 09 Feb 2007 01:55:39 +0900 (JST)
Message-ID: <20070209.015539.53640067.yoshfuji@linux-ipv6.org>
References: <20070208163211.23973.5877.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	hch@infradead.org, arjan@infradead.org, yoshfuji@linux-ipv6.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54212 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423224AbXBHQyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 11:54:17 -0500
In-Reply-To: <20070208163211.23973.5877.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070208163211.23973.5877.stgit@warthog.cambridge.redhat.com> (at Thu, 08 Feb 2007 16:32:11 +0000), David Howells <dhowells@redhat.com> says:

>  (2) A local address can optionally be bound:
> 
> 	struct sockaddr_rxrpc srx = {
> 		.srx_family	= AF_RXRPC,
> 		.srx_service	= 0,  /* we're a client */
> 		.transport_type	= SOCK_DGRAM,	/* type of transport socket */
> 		.transport.sin_family	= AF_INET,
> 		.transport.sin_port	= htons(7000), /* AFS callback */
> 		.transport.sin_address	= 0,  /* all local interfaces */
> 	};

This sockaddr_rxrpc{} should NOT include sockaddr_in{} directly.
Please use sockaddr_storage{} (or sockaddr{}, maybe), and make it
sure to align on 64-bit word.

--yoshfuji
