From: Sujith Manoharan <sujith@msujith.org>
Subject: Re: TCP performance regression
Date: Mon, 11 Nov 2013 21:43:51 +0530
Message-ID: <21121.575.539384.948990@gargle.gargle.HOWL>
References: <21120.27501.32323.332316@gargle.gargle.HOWL>
	<1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<21120.29720.673157.151074@gargle.gargle.HOWL>
	<1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com>
	<21120.37647.979237.40802@gargle.gargle.HOWL>
	<1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd@openwrt.org>, netdev@vger.kernel.org,
	Dave Taht <dave.taht@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s72.web-hosting.com ([198.187.29.21]:45875 "EHLO
	s72.web-hosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753867Ab3KKQS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 11:18:27 -0500
In-Reply-To: <1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> We have many choices.
> 
> 1) Add back a minimum of ~128 K of outstanding bytes per TCP session,
>    so that buggy drivers can sustain 'line rate'.
> 
>    Note that with 100 concurrent TCP streams, total amount of bytes
>    queued on the NIC is 12 MB.
>    And pfifo_fast qdisc will drop packets anyway.
> 
>    Thats what we call 'BufferBloat'
> 
> 2) Try lower values like 64K. Still bufferbloat.
> 
> 3) Fix buggy drivers, using a proper logic, or shorter timers (mvneta
> case for example)
> 
> 4) Add a new netdev attribute, so that well behaving NIC drivers do not
> have to artificially force TCP stack to queue too many bytes in
> Qdisc/NIC queues.

I think the quirks of 802.11 aggregation should be taken into account.
I am adding Felix to this thread, who would have more to say on latency/bufferbloat
with wireless drivers.

Sujith
