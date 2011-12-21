From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] IPv6 : add multicast routing verify which
 net_device is lo
Date: Wed, 21 Dec 2011 01:15:06 -0500 (EST)
Message-ID: <20111221.011506.1770356582907889299.davem@davemloft.net>
References: <4EF059B3.1020705@cn.fujitsu.com>
	<1324379424-18055-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wangxingtong@cn.fujitsu.com
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537Ab1LUGPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 01:15:12 -0500
In-Reply-To: <1324379424-18055-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Tue, 20 Dec 2011 19:10:24 +0800

> In currently routing subsystem, when we lookup a multicast routing
> to send muticast packets to outside, rt6_device_match will return
> the rt6_info which it's match first. If we add a multicast route on
> loopback devices beforce the others interface, rt6_device_match will
> retrun the rt6_info which rt6i_dev->name is "lo". But, obviously,
> we can't send a muticast packet to outside using loopback devices.
> It case all multicast packets blocking.
> 
> Commit 4af04aba93f47699e disabled kernel add multicast route on lo
> automatically. However,  we can't surmise the routing-add order or
> interdict add multicast routing on loopback devices in user space.
> The bug still exist. So, i think, more stronger routing subsystem is
> necessary.
> 
> Signed-off-by: Wang xingtong <wangxingtong@cn.fujitsu.com>

Ok, this is getting rediculious.  I want to revert all of this
stuff.

How about, instead, we stop userland adding explicit addresses to the
loopback device since that's what started behaving differently
recently and causes these problems in the first place?
