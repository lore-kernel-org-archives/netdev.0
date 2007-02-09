From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation
Date: Fri, 09 Feb 2007 13:45:43 +0000
Message-ID: <22288.1171028743@redhat.com>
References: <20070209.221453.16393835.yoshfuji@linux-ipv6.org>  <20070209.015539.53640067.yoshfuji@linux-ipv6.org> <20070208163211.23973.5877.stgit@warthog.cambridge.redhat.com> <10385.1171024283@redhat.com>
Cc: dhowells@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	herbert.xu@redhat.com, hch@infradead.org, arjan@infradead.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41487 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946464AbXBINqC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 08:46:02 -0500
In-Reply-To: <20070209.221453.16393835.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> wrote:

> Because it is protocol (such as ipv4 or ipv6) dependent.

Hmmm...  I had thought of RxRPC being very transport dependent, being rather
tied to UDPv4, though probably simply extensible to UDPv6.  However, as long
as the transport-layer header is removed on received packets before the main
part of the code sees them, there shouldn't be any problem supporting non-UDP
protocols, apart from, possibly, network error (ICMP) handling.

Some of the AFS operations, however, only deal in IPv4 addresses.  I believe
there is work afoot to deal with this, but I as far as I know it hasn't been
dealt with yet.

Currently RxRPC is *only* available over UDPv4 in OpenAFS as far as I know.

> You cannot use different sturcture for one address family.
> You could use union, maybe.

I am using a union:

	struct sockaddr_rxrpc {
		sa_family_t	srx_family;
		u16		srx_service;
		u16		transport_type;
		u16		transport_len;
		union {
			sa_family_t family;
			struct sockaddr_in sin;
			struct sockaddr_in6 sin6;
		} transport;
	};

I can add the alignment restrictor to the union though.

> Another option would be to introduce new transport protocol such as
> dccp or sctp, no?

It's not my choice.  My code must interoperate with the other RxRPC/AFS
implementations that are already out there and have been around for many
years.

David
