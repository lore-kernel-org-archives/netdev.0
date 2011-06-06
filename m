From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] should we care of COMPAT mode in bridge ?
Date: Mon, 06 Jun 2011 13:09:58 -0700 (PDT)
Message-ID: <20110606.130958.1488166895702555231.davem@davemloft.net>
References: <1307389540.2642.3.camel@edumazet-laptop>
	<201106062206.29134.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757171Ab1FFUKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 16:10:05 -0400
In-Reply-To: <201106062206.29134.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 6 Jun 2011 22:06:28 +0200

> On Monday 06 June 2011 21:45:40 Eric Dumazet wrote:
>> While trying Alexander Holler patch, I found a 32bit brctl program was
>> not able to work on a 64bit kernel. So I had to switch to another
>> machine for my tests.
>> 
>> brctl addbr mybridge
>> ->
>> socket(PF_FILE, SOCK_STREAM, 0)         = 3
>> ioctl(3, SIOCSIFBR, 0xffd509c0)         = -1 EINVAL (Invalid argument)
>> 
>> Should we care or not ?
>> 
> 
> Generally, we try to make all ioctls work in compat mode. For the old
> bridge ioctls, this is currently impossible because it uses SIOCPRIVATE
> ioctls, but it would be easy to add an ndo_do_compat_ioctl. 

Right, we need to funnel compat ioctls down to the device and add a
->ndo_compat_ioctl() or similar, if that is indeed feasible.
