From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [NETLINK]: Restore API compatibility of address and neighbour
 bits
Date: Sat, 9 Dec 2006 10:56:50 +0100 (MET)
Message-ID: <200612091057.30071.stefan@loplof.de>
References: <20061207.025140.75779834.davem@davemloft.net>
 <200612081526.12651.stefan@loplof.de>
 <20061208.133334.55725556.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, dwmw2@infradead.org, joseph@codesourcery.com,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p07-ob.rzone.de ([81.169.146.188]:10185 "EHLO
	mo-p07-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935001AbWLIJ6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 04:58:37 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061208.133334.55725556.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, 8. Dezember 2006 22:33 schrieb David Miller:

> [IF(L)A_(RTA|PAYLOAD) macros]
>
> iproute got fixed, dhcpclient and friends should get fixed to not use
> them either

Today's git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git 
contains stuff like

#ifndef IFA_RTA
#define IFA_RTA(r) \
        ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct 
ifaddrmsg))))
#endif

and still uses these macros in various places. I wouldn't call that fixed.

Even though the macros are back now, what is the suggested replacement for 
userspace programs? The new nla_get_*()-inlines in net/netlink.h are not even 
exported by make headers_install.

For new projects, I'll just use libnetlink. dhcpclient however is also 
targeted at embedded systems (and has been used to learn about netlink ;-), 
so I don't plan to link it to another not so small library.

Stefan
