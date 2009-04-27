From: David Miller <davem@davemloft.net>
Subject: Re: skb_warn_if_lro(skb) in ip_forward()
Date: Mon, 27 Apr 2009 00:04:13 -0700 (PDT)
Message-ID: <20090427.000413.208482056.davem@davemloft.net>
References: <dac45060904262343v481d2665s4074e901852406b5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: markryde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42823
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752522AbZD0HEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 03:04:20 -0400
In-Reply-To: <dac45060904262343v481d2665s4074e901852406b5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Ryden <markryde@gmail.com>
Date: Mon, 27 Apr 2009 09:43:39 +0300

> Hello,
> 
> I would appreciate if somebody will explain in a few sentences, why,
> when forwarding
> a packet in IPV4 , in ip_forward() method, (net/ipv4/ip_forward.c) we
> drop the packet
> if it is lro.

Because we have no means by which to reconstitute the original
sub-frames so that we can forward them properly.

This is why, when forwarding or bridging is enabled on an interface
we disable LRO on all devices involved.  Therefore we should never
see LRO frames here.
