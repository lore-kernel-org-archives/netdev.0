From: Thomas Graf <tgraf@suug.ch>
Subject: Re: network interface *name* alias support?
Date: Wed, 28 May 2008 00:11:58 +0200
Message-ID: <20080527221158.GC20815@postel.suug.ch>
References: <48387B18.2090300@trash.net> <alpine.LNX.1.10.0805242254020.19084@fbirervta.pbzchgretzou.qr> <4838D7E4.7050401@trash.net> <20080525.051713.124717485.davem@davemloft.net> <20080527190352.GE25696@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	jengelh@medozas.de, dwmw2@infradead.org, jchapman@katalix.com,
	jonathan@jonmasters.org, rick.jones2@hp.com,
	auke-jan.h.kok@intel.com, johnathan@jonmasters.org,
	netdev@vger.kernel.org
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:45941 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754646AbYE0WLi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 18:11:38 -0400
Content-Disposition: inline
In-Reply-To: <20080527190352.GE25696@auslistsprd01.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Matt Domsch <Matt_Domsch@dell.com> 2008-05-27 14:03
> Network devices have no such thing that I can tell.  I get at the
> device names (as presently assigned) by reading /proc/net/dev (I'd be
> happy to be told of a more correct way - this is what net-tools uses.)
> The moment I've finished reading this though, another process can come
> along and change these devices names.  Now every ioctl() my code makes
> could fail because the name (in struct ifreq) is the handle used for
> such calls.  One could argue it's a rare thing to change device
> names...

Regardless of whether you identify the link by name or slot, you
should translate the name/slot to ifindex and use netlink requests
to manipulate links. The ifindex is not going to change and won't
be reused by new links until the (large) counter overflows. Therefore
the chance of modyfing a wrong link is close to zero.
