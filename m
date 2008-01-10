From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Thu, 10 Jan 2008 12:45:53 -0800
Message-ID: <23999.1199997953@death>
References: <Pine.LNX.4.64.0801081949290.1135@bizon.gios.gov.pl> <29560.1199820632@death> <Pine.LNX.4.64.0801090732490.1135@bizon.gios.gov.pl> <17850.1199865514@death> <20080109152740.GE8728@gospo.usersys.redhat.com> <32361.1199901296@death> <20080109201709.GF8728@gospo.usersys.redhat.com> <20080109220534.GA2692@gondor.apana.org.au> <7603.1199920750@death> <20080110005809.GA3851@gondor.apana.org.au> <20080110145144.GH8728@gospo.usersys.redhat.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:35127 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751020AbYAJUp7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 15:45:59 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0AKjuJi028359
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 15:45:56 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0AKjujk110516
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 15:45:56 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0AKjt52031048
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 15:45:56 -0500
In-reply-to: <20080110145144.GH8728@gospo.usersys.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:
[...]
>That wasn't the only purpose, Herbert.  Making sure that calls to
>dev_set_mac_address were called from process context was important at
>the time of the coding as well since at least the tg3 driver took locks
>that could not be taken reliably in soft-irq context.  Michael Chan
>fixed this here:
>
>commit 986e0aeb9ae09127b401c3baa66f15b7a31f354c
>Author: Michael Chan <mchan@broadcom.com>
>Date:   Sat May 5 12:10:20 2007 -0700
>
>    [TG3]: Remove reset during MAC address changes.
>
>so if wasn't as much of an issue after that, but moving as much of the
>code to process context was important for that as well (hence the move
>to not continue to try to not use bh-locks everywhere).

	Well, not for tg3 perhaps, but other network device drivers do
the same thing (if memory serves, any USB ethernet adapter will have
issues there).  Also, I believe the netlink notifier callback,
rtnetlink_event, which every dev_set_whatever calls, does a
possibly-sleeping memory allocation (rtmsg_ifinfo -> nlmsg_new ->
alloc_skb(GFP_KERNEL)); so we don't really want to hold extra locks for
that, either.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
