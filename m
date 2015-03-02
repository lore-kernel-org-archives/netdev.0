From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] net: add IPv4 routing FIB support for
 switchdev
Date: Mon, 02 Mar 2015 17:34:52 -0500 (EST)
Message-ID: <20150302.173452.95760557580052043.davem@davemloft.net>
References: <1425288555-22598-3-git-send-email-sfeldma@gmail.com>
	<20150302.132015.1646795699731313510.davem@davemloft.net>
	<CAE4R7bAwC5QvteamkHs+J609DTM=jqNQeKLmEWResF0RLAD8WQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbbCBWey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 17:34:54 -0500
In-Reply-To: <CAE4R7bAwC5QvteamkHs+J609DTM=jqNQeKLmEWResF0RLAD8WQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>
Date: Mon, 2 Mar 2015 14:28:55 -0800

> On Mon, Mar 2, 2015 at 10:20 AM, David Miller <davem@davemloft.net> wrote:
>> If you see a multi-nexthop route, for this initial implementation,
>> you will need to uninstall all routes from the hardware.
> 
> I don't follow that?  In this initial implementation, rocker rejects
> ECMP routes, returning -EOPNTOSUPP, but the route is still installed
> in the kernel.  I'm not seeing why we'd need to uninstall from hw all
> the single-path routes.

I think we need to clear up what -EOPNOTSUPP actually means.

Your FIB layer logic is fine _iff_ a driver always returns -EOPNOTSUPP
for any and all routes ("I can't support hw offloading no matter
what").

With that exact behavior it is valid to only install into the software
tables when that error code is seen.

But if your make -EOPNOTSUPP get returned for some routes and not for
others, then you have to clear the hw devices tables completely before
you can legally proceed to successfully install into the software
tables.

We have to avoid, in any and all cases, any potential situation where
we can have some entries programmed into the hardware and some not.

It's either all or nothing in this initial implementation.
