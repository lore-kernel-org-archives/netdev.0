From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New Qlogic 10Gb Ethernet driver for 2.6.28
Date: Fri, 22 Aug 2008 02:42:52 -0700 (PDT)
Message-ID: <20080822.024252.193704871.davem@davemloft.net>
References: <20080821185402.GD31526@susedev.qlogic.org>
	<48AE8549.6090705@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux-Driver@qlogic.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44813
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752835AbYHVJmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 05:42:53 -0400
In-Reply-To: <48AE8549.6090705@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 22 Aug 2008 05:22:17 -0400

> - The kmap use is interesting

It's so much easier to just always tack on the pages or whatever
and use __pskb_pull_tail(skb, SOME_MIN_HEADER_LENGTH)

I also notice that this driver does not do:

	skb_reserve(skb, NET_IP_ALIGN);

on RX packets to get the IP headers properly 4-byte aligned aligned
after the ethernet header.
