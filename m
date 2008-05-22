From: David Miller <davem@davemloft.net>
Subject: Re: Single packet receiving in multiple ring buffers
Date: Thu, 22 May 2008 11:57:55 -0700 (PDT)
Message-ID: <20080522.115755.202204829.davem@davemloft.net>
References: <20080522181401.GA14056@2ka.mipt.ru>
	<31256957387BB54C8B9AFE88AA5C0564044A1846@SDCEXCHANGE01.ad.amcc.com>
	<20080522184906.GA32582@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kchudgar@amcc.com, kchudgar.linux@gmail.com, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42712
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751234AbYEVS6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 14:58:00 -0400
In-Reply-To: <20080522184906.GA32582@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 22 May 2008 22:49:07 +0400

> You have to copy part of the data (up to and including transport headers)
> into skb->data.

You don't necessarily have to.  The input paths of the networking
stack will pull into the skb->data, as needed, using
pskb_may_pull() calls.

I did some tests with the NIU driver on receive, and to be
honest there was nearly zero performance gain from pre-copying
into skb->data from the paged SKB area preemptively before
passing the packet in via netif_receive_skb().
