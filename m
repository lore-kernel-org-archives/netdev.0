From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 1/8] Create ipv4_is_<type>(__be32 addr)
 functions
Date: Mon, 17 Dec 2007 14:43:19 -0800 (PST)
Message-ID: <20071217.144319.93471413.davem@davemloft.net>
References: <1197589141-7020-1-git-send-email-joe@perches.com>
	<Pine.LNX.4.64.0712172333550.32270@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jengelh@computergmbh.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S936953AbXLQWne@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0712172333550.32270@fbirervta.pbzchgretzou.qr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@computergmbh.de>
Date: Mon, 17 Dec 2007 23:37:24 +0100 (CET)

> 
> On Dec 13 2007 15:38, Joe Perches wrote:
> >+static inline bool ipv4_is_private_10(__be32 addr)
> >+{
> >+	return (addr & htonl(0xff000000)) == htonl(0x0a000000);
> >+}
> 
> What are these functions needed for, even? There does not seem to be
> any code (at least in davem's net-2.6.25:net/ipv4/, where I dared to grep)
> that uses them.

You really need to grep the whole tree, never ever decrease the scope
of directories to search if you want to see if an interface is used.

It's used by some ipv6 address translation code as well as some
bits in SCTP:

include/net/addrconf.h:	eui[0] = (ipv4_is_zeronet(addr) || ipv4_is_private_10(addr) ||
net/sctp/protocol.c:	} else if (ipv4_is_private_10(addr->v4.sin_addr.s_addr) ||

So lazy...
