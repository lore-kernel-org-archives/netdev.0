From: Sujith Manoharan <sujith@msujith.org>
Subject: Re: TCP performance regression
Date: Mon, 11 Nov 2013 11:37:20 +0530
Message-ID: <21120.29720.673157.151074@gargle.gargle.HOWL>
References: <21120.27501.32323.332316@gargle.gargle.HOWL>
	<1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s72.web-hosting.com ([198.187.29.21]:34959 "EHLO
	s72.web-hosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220Ab3KKGLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 01:11:45 -0500
In-Reply-To: <1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> I am afraid this commit shows bugs in various network drivers.
> 
> All drivers doing TX completion using a timer are buggy.
> 
> Holding skb 10 ms before TX completion is totally wrong and must be fixed.
> 
> If really NIC is not able to trigger an interrupt after TX completion, then
> driver should call skb_orphan() in its ndo_start_xmit()

802.11 AMPDU formation is done in the TX completion path in ath9k.

Incoming frames are added to a software queue and the TX completion
tasklet checks if enough frames are available to form an aggregate and
if so, forms new aggregates and transmits them.

There is no timer involved, but the completion routine is rather heavy.
Many wireless drivers handle 802.11 aggregation in this way:
ath9k, ath9k_htc, ath10k etc.

Sujith
