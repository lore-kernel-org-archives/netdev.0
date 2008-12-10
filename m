From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 3/3]ipv6:fix the outgoing interface selection
 order in udpv6_sendmsg()
Date: Tue, 09 Dec 2008 22:16:11 -0800 (PST)
Message-ID: <20081209.221611.26561529.davem@davemloft.net>
References: <493E1A7B.9070208@cn.fujitsu.com>
	<200812090932.56865.remi.denis-courmont@nokia.com>
	<493F106C.8030803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: remi.denis-courmont@nokia.com, netdev@vger.kernel.org
To: yanghy@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58571
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750736AbYLJGQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 01:16:11 -0500
In-Reply-To: <493F106C.8030803@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Hongyang <yanghy@cn.fujitsu.com>
Date: Wed, 10 Dec 2008 08:42:20 +0800

> If outgoing interface is set with SO_BINDTODEVICE and also sticky pktinfo
> the outgoing interface is exactly what SO_BINDTODEVICE set,because in my
> first patch,when set sticy pktinfo,outgoing interface set by SO_BINDTODEVICE
> is checked:
> 
> +		if(sk->sk_bound_dev_if && pkt.ipi6_ifindex != sk->sk_bound_dev_if)
> +			goto e_inval;
> 

You may be checking this, but these two values can become out of sync
if the application next makes a SO_BINDTODEVICE setsockopt() call to
change the index setting.

Nothing makes sure the sticky ipv6 socket information is updated
if that happens.  And the most obvious ways to handle that are
very ugly, doing some kind of call into ipv6 from the generic
socket SO_BINDTODEVICE setsockopt() handler.
