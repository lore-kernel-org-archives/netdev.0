From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation
Date: Fri, 09 Feb 2007 22:14:53 +0900 (JST)
Message-ID: <20070209.221453.16393835.yoshfuji@linux-ipv6.org>
References: <20070209.015539.53640067.yoshfuji@linux-ipv6.org>
	<20070208163211.23973.5877.stgit@warthog.cambridge.redhat.com>
	<10385.1171024283@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	hch@infradead.org, arjan@infradead.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54388 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946444AbXBINOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 08:14:55 -0500
In-Reply-To: <10385.1171024283@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <10385.1171024283@redhat.com> (at Fri, 09 Feb 2007 12:31:23 +0000), David Howells <dhowells@redhat.com> says:

> YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> wrote:
> 
> > and make it sure to align on 64-bit word.
> 
> The first part of sockaddr_rxrpc is exactly 64 bits; then comes the transport
> address, so that's okay.
> 
> > This sockaddr_rxrpc{} should NOT include sockaddr_in{} directly.
> > Please use sockaddr_storage{} (or sockaddr{}, maybe),
> 
> Why can't I include sockaddr_in and sockaddr_in6 in sockaddr_rxrpc, btw?

Because it is protocol (such as ipv4 or ipv6) dependent.
You cannot use different sturcture for one address family.
You could use union, maybe.

> > > That won't work.  That would then make the address larger than the maximum
> > > size (ie: sizeof(struct sockaddr_storage)).
> > 
> > sockaddr{}, then...
> 
> But that's not big enough to hold a sockaddr_in6...

struct sockaddr_rxrpc {
 ...
 union {
   struct sockaddr rxrpc_sa;
   struct sockaddr_in rxrpc_sin;
   struct sockaddr_in6 rxrpc_sin6;
 } __attribute__((__aligned(8)__));
};

Another option would be to introduce new transport protocol such as
dccp or sctp, no?

--yoshfuji
