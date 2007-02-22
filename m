From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation
Date: Thu, 22 Feb 2007 13:02:27 +0000
Message-ID: <1808.1172149347@redhat.com>
References: <20070209.015539.53640067.yoshfuji@linux-ipv6.org>  <20070208163211.23973.5877.stgit@warthog.cambridge.redhat.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	hch@infradead.org, arjan@infradead.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750706AbXBVNC5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 08:02:57 -0500
In-Reply-To: <20070209.015539.53640067.yoshfuji@linux-ipv6.org> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> wrote:

> This sockaddr_rxrpc{} should NOT include sockaddr_in{} directly.
> Please use sockaddr_storage{} (or sockaddr{}, maybe), and make it
> sure to align on 64-bit word.

How about this then:

struct sockaddr_rxrpc {
	sa_family_t	srx_family;	/* address family */
	u16		srx_service;	/* service desired */
	u16		transport_type;	/* type of transport socket (SOCK_DGRAM) */
	u16		transport_len;	/* length of transport address */
	struct sockaddr	srx_sa[0];	/* address of transport endpoint */
};

Then whoever wants to use it must follow it immediately with an address of the
appropriate type.  The length given to connect or bind would then be the
combined length of the two addresses.

Someone could then set one up on the stack by this sort of thing:

	int zebra(int fd)
	{
		struct {
			struct sockaddr_rxrpc srx;
			struct sockaddr_in sin;
		} sa;

		...
		if (connect(fd, (struct sockaddr *) &sa, sizeof(sa)) < 0)
			...
		...
	}

David
